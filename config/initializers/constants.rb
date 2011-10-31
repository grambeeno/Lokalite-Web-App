if Rails.env == 'production'
  REPORT_GRID_MASTER_TOKEN = 'D90AEC76-FAC1-4591-8726-2126832BD18D'
  REPORT_GRID_WRITE_TOKEN = '86189E2B-D0F2-4606-B80A-247FBD5F4365'
  REPORT_GRID_READ_TOKEN = 'ABCBE5EE-ABB6-4383-85BE-144EEE88CD49'
  FACEBOOK_APP_ID     = '206217952760561'
  FACEBOOK_APP_SECRET = 'afe5d856290c63a336deaf408b3ae425'
else
  REPORT_GRID_MASTER_TOKEN = 'FD2973F7-A5E1-4692-B9C8-111D0E62CB78'
  REPORT_GRID_WRITE_TOKEN = '944D5A30-020D-4FA7-ACBC-7441ABAFE3E3'
  REPORT_GRID_READ_TOKEN = 'D3B7D736-3602-417D-8B9D-570DDB368E6A'
  FACEBOOK_APP_ID     = '221397624592914'
  FACEBOOK_APP_SECRET = '74edaeb242da1bdb0a8c2f8dfd055b19'
end


# an array of pairs for a select
# [human_pickable_time, seconds]
DURATIONS = []
96.times do |index|
  count   = index + 1
  seconds = count * 15.minutes
  string  = (count/4).to_s

  case count % 4
  when 0
    string << '.00'
  when 1
    string << '.25'
  when 2
    string << '.50'
  when 3
    string << '.75'
  end

  if string == '1.00'
    string << ' Hour'
  else
    string << ' Hours'
  end

  DURATIONS << [string, seconds]
end


US_STATES = {
  'AL' => 'Alabama',
  'AK' => 'Alaska',
  'AS' => 'America Samoa',
  'AZ' => 'Arizona',
  'AR' => 'Arkansas',
  'CA' => 'California',
  'CO' => 'Colorado',
  'CT' => 'Connecticut',
  'DE' => 'Delaware',
  'DC' => 'District of Columbia',
  'FM' => 'Micronesia',
  'FL' => 'Florida',
  'GA' => 'Georgia',
  'GU' => 'Guam',
  'HI' => 'Hawaii',
  'ID' => 'Idaho',
  'IL' => 'Illinois',
  'IN' => 'Indiana',
  'IA' => 'Iowa',
  'KS' => 'Kansas',
  'KY' => 'Kentucky',
  'LA' => 'Louisiana',
  'ME' => 'Maine',
  'MH' => 'Islands1',
  'MD' => 'Maryland',
  'MA' => 'Massachusetts',
  'MI' => 'Michigan',
  'MN' => 'Minnesota',
  'MS' => 'Mississippi',
  'MO' => 'Missouri',
  'MT' => 'Montana',
  'NE' => 'Nebraska',
  'NV' => 'Nevada',
  'NH' => 'New Hampshire',
  'NJ' => 'New Jersey',
  'NM' => 'New Mexico',
  'NY' => 'New York',
  'NC' => 'North Carolina',
  'ND' => 'North Dakota',
  'OH' => 'Ohio',
  'OK' => 'Oklahoma',
  'OR' => 'Oregon',
  'PW' => 'Palau',
  'PA' => 'Pennsylvania',
  'PR' => 'Puerto Rico',
  'RI' => 'Rhode Island',
  'SC' => 'South Carolina',
  'SD' => 'South Dakota',
  'TN' => 'Tennessee',
  'TX' => 'Texas',
  'UT' => 'Utah',
  'VT' => 'Vermont',
  'VI' => 'Virgin Island',
  'VA' => 'Virginia',
  'WA' => 'Washington',
  'WV' => 'West Virginia',
  'WI' => 'Wisconsin',
  'WY' => 'Wyoming'
}


EVENT_CATEGORIES = [
  'Happy Hour',
  'Music and The Arts',
  'Nightlife',
  'Shopping',
  'Food and Dining',
  'Sports and Fitness',
  'Health and Beauty',
  'Learn Something New',
  'Campus',
  'Community',
  'Tours and Tastings',
  'MMJ'
]

ORGANIZATION_CATEGORIES = [
  'Shopping',
  'Restaurants and Bars',
  'Coffee and Tea',
  'Arts and Entertainment',
  'Services',
  'Campus',
  'Beer Wine and Spirits',
  'Sports and Fitness',
  'Health and Beauty',
  'Non-Profit',
  'MMJ'
]

