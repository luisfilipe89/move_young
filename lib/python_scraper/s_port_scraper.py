from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import time
import json

# Setup browser
options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
options.add_argument("--headless=new")
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# Load page
driver.get("https://www.aanbod.s-port.nl/activiteiten")
print("✅ Page loaded, scrolling...")

# Scroll to load dynamic content
for i in range(10):
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    print(f"🔄 Scroll attempt {i + 1}")
    time.sleep(2.5)

# Wait for activity cards
try:
    WebDriverWait(driver, 20).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, ".text h2 a"))
    )
except:
    print("❌ Timeout waiting for events")
    driver.save_screenshot("no_events_found.png")
    driver.quit()
    raise Exception("No events found")

# Parse event data
event_containers = driver.find_elements(By.CSS_SELECTOR, ".text")
print(f"\n✅ Found {len(event_containers)} events")

all_events = []

for card in event_containers:
    try:
        title_elem = card.find_element(By.CSS_SELECTOR, "h2 a")
        title = title_elem.text.strip()
        url = title_elem.get_attribute("href")
        organizer = card.find_element(By.CSS_SELECTOR, ".location").text.strip()

        info_items = card.find_elements(By.CSS_SELECTOR, ".info li div:nth-child(2)")
        location = info_items[0].text.strip() if len(info_items) > 0 else "-"
        target_group = info_items[1].text.strip() if len(info_items) > 1 else "-"
        date_time = info_items[2].text.strip() if len(info_items) > 2 else "-"

        cost_elements = card.find_elements(By.CSS_SELECTOR, ".info + .costs li")
        cost = cost_elements[0].text.strip() if cost_elements else "-"

        # Print for verification
        print(f"\n📌 Title: {title}")
        print(f"🔗 URL: {url}")
        print(f"🎯 Organizer: {organizer}")
        print(f"📍 Location: {location}")
        print(f"👥 Target: {target_group}")
        print(f"🗓️ Date & Time: {date_time}")
        print(f"💰 Cost: {cost}")

        all_events.append({
            "title": title,
            "url": url,
            "organizer": organizer,
            "location": location,
            "target_group": target_group,
            "date_time": date_time,
            "cost": cost
        })

    except Exception as e:
        print("⚠️ Failed to parse one event:", e)

# Save to JSON
with open("lib/python_scraper/upcoming_events.json", "w", encoding="utf-8") as f:
    json.dump(all_events, f, ensure_ascii=False, indent=2)

print("\n✅ Saved events to upcoming_events.json")
driver.quit()
