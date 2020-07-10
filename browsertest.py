from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import time
import os
import base64
import io
import numpy as np
import traceback

from PIL import Image

def main():
  multi = os.environ.get('MULTI')
  if multi:
    for options in parse_multiple(multi):
      # Can't get gevent working around this yet, no parallel runners
      try:
        driver = getDriver(options)
      except Exception as e:
        traceback.print_exc()
        print('Error launching driver', options, e)
      try:
        run_test(driver)
      except Exception as e:
        traceback.print_exc()
        print('[%s] Test failed!' % driver.nickname)
  else:
    run_test(getDriver()) # detect single browser from ENV, or default chrome

def parse_multiple(multi):
  for part in multi.split(','):
    parts = part.split('/')
    if len(parts) == 3:
      platform, browser, browser_version = parts
    if len(parts) == 2:
      platform, browser = parts
      browser_version = None
    if len(parts) == 1:
      browser = parts[0]
      platform = browser_version = None
    yield {
      'browser': browser,
      'platform': platform,
      'browser_version': browser_version,
    }
  
def run_test(driver):
  try:
    assert not checkPink(driver, timeout=1), "Should not detect pink on a blank page"
    loadRoom(driver)
    assert checkPink(driver), "Should detect pink in a chatroom"
  finally:
    driver.quit()

def getDriver(options=None):
  if 'BROWSERSTACK_URL' in os.environ:
    options = options or {
      'browser' : os.environ.get('BROWSER', 'chrome'),
      'browser_version' : os.environ.get('BROWSER_VERSION', None),
      'platform' : os.environ.get('PLATFORM', 'windows'),
    }

    options['job_id'] = os.environ.get('JOB_ID', None)
    options['name'] = "ion e2e #%s"%options['job_id']
    driver = remoteDriver(os.environ['BROWSERSTACK_URL'], options)
  else:
    driver = localDriver()
    options = {
      'browser': 'chrome',
      'platform': 'local',
    }
    options['job_id'] = os.environ.get('JOB_ID', None)
    options['name'] = "ion e2e #%s"%options['job_id']
  setattr(driver, 'nickname', f"{options['platform']}-{options['browser']}-{options['browser_version'] or 'latest'}#{options['job_id']}")
  setattr(driver, '_options', options)

  return driver


def remoteDriver(url, options):
  return webdriver.Remote(command_executor=url, desired_capabilities=options)

def localDriver():
  return webdriver.Chrome()

def screenshot(driver, extra=None):
  os.makedirs("screenshots/%s"%driver.nickname, exist_ok=True)
  extra = extra and '-%s'%extra or ''
  driver.get_screenshot_as_file('screenshots/%s/%s%s.png'%(driver.nickname,int(time.time()), extra))

def loadRoom(driver, room=None, username=None): 
  room = room or os.environ.get('ION_ROOM', 'test-pink-video')
  print("[%s] Initialized!"%driver.nickname)
  driver.get(os.environ.get('URL', 'http://localhost:9090'))
  print("[%s] Loaded page:"%driver.nickname, driver.title)
  time.sleep(2)
  screenshot(driver, 'loaded')
  driver.find_element_by_id("login_roomId").send_keys(room)
  driver.find_element_by_id("login_displayName").send_keys(username or os.environ.get('ION_USERNAME', 'browsertest.py'))
  driver.find_element_by_class_name("login-join-button").click()
  screenshot(driver, 'form-fill')
  print("[%s] Joining room %s..."%(driver.nickname, room))

def checkPink(driver, timeout=15):
  start = time.time()
  while time.time() - start < timeout:
    screenshot(driver)
    imgdata = base64.b64decode(str(driver.get_screenshot_as_base64()))
    image = Image.open(io.BytesIO(imgdata))
    two_d = np.array(image)
    for row in two_d:
      for color in row:
        R, G, B, A = color
        # Fuzzy matching because the pink doesn't come out exact
        if R > 240 and B > 240 and A == 255 and G < 35:
          print('[%s]'%driver.nickname, 'Pink detected', color)
          return True
    time.sleep(1)
  return False

if __name__ == '__main__': main()