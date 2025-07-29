import requests
from bs4 import BeautifulSoup

def fetch_sport_events():
    url = 'https://www.aanbod.s-port.nl/'
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    # Find all event blocks
    events = []
    event_blocks = soup.find_all('div', class_='info')
    
    for block in event_blocks:
        try:
            title = block.find('font').get_text(strip=True)
            
            location_tag = block.find('i', class_='fa-map-marker-alt')
            location = location_tag.find_next('div').get_text(strip=True) if location_tag else 'Unknown'

            user_tag = block.find('i', class_='fa-user')
            user_info = user_tag.find_next('div').get_text(strip=True) if user_tag else 'Unknown'

            calendar_tag = block.find('i', class_='fa-calendar-alt')
            date = calendar_tag.find_next('div').get_text(strip=True) if calendar_tag else 'Unknown'

            more_info = block.find('a', title=lambda t: t and 'More information' in t)
            link = more_info['href'] if more_info else None

            events.append({
                'title': title,
                'location': location,
                'target_group_and_cost': user_info,
                'date': date,
                'link': f"https://www.aanbod.s-port.nl{link}" if link else None,
            })
        except Exception as e:
            print("Error parsing event:", e)

    return events

if __name__ == '__main__':
    events = fetch_sport_events()
    for e in events:
        print(e)
