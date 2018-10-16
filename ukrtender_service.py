# coding=utf-8
from datetime import datetime, timedelta
import dateutil.parser
import pytz
import urllib
import shutil
import os

TZ = pytz.timezone('Europe/Kiev')


def adapt_data(data):
    
#cat    data['data']['procuringEntity']['name'] = 'testuser_tender_owner'
    data['data']['items'][0]['unit']['name'] = get_unit_name(data['data']['items'][0]['unit']['name'])
#cat     data['data']['items'][0]['deliveryAddress']['region'] = get_unit_region(data['data']['items'][0]['deliveryAddress']['region'])
    data['data']['items'][0]['deliveryAddress']['region'] = get_delivery_region(data['data']['items'][0]['deliveryAddress']['region'])
    data['data']['items'][0]['deliveryAddress']['locality'] = convert_locality(data['data']['items'][0]['deliveryAddress']['locality'])
    data['data']['items'][0]['deliveryDate']['startDate'] = adapt_delivery_date(data['data']['items'][0]['deliveryDate']['startDate'])
    data['data']['items'][0]['deliveryDate']['endDate'] = adapt_delivery_date(data['data']['items'][0]['deliveryDate']['endDate'])
    data['data']['items'][1]['deliveryDate']['startDate'] = adapt_delivery_date(data['data']['items'][1]['deliveryDate']['startDate'])
    data['data']['items'][1]['deliveryDate']['endDate'] = adapt_delivery_date(data['data']['items'][1]['deliveryDate']['endDate'])
    return data

def adapt_data_view(data):
    data['data']['items'][0]['deliveryDate']['startDate'] = adapt_delivery_date(data['data']['items'][0]['deliveryDate']['startDate'])
    data['data']['items'][0]['deliveryDate']['endDate'] = adapt_delivery_date(data['data']['items'][0]['deliveryDate']['endDate'])
    data['data']['items'][1]['deliveryDate']['startDate'] = adapt_delivery_date(data['data']['items'][1]['deliveryDate']['startDate'])
    data['data']['items'][1]['deliveryDate']['endDate'] = adapt_delivery_date(data['data']['items'][1]['deliveryDate']['endDate'])
    return data

def download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))


#def download_file(url, file_name):
#    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
#    urllib.urlretrieve(url, os.path.join(output_dir, file_name))


def get_type_field(field):
    value = ['description', 'classification.scheme', 'deliveryDate.startDate', 'deliveryDate.endDate', 'deliveryAddress.postalCode', 'deliveryAddress.region',
             'deliveryAddress.streetAddress',
             'additionalClassifications.id', 'classification.id', 'classification.description', 'unit.code', 'deliveryLocation.latitude',
             'deliveryLocation.longitude', 'quantity', 'deliveryAddress.locality',
             'title', 'value.amount', 'value.valueAddedTaxIncluded', 'minimalStep.amount',
             'minimalStep.valueAddedTaxIncluded', 'unit.name', 'deliveryAddress.countryName', 'value.currency', 'minimalStep.currency',
			 'auctionPeriod.startDate', 'auctionPeriod.endDate', 'procurementMethodType', 'featureOf'
			 ]

    text = ['additionalClassifications.scheme', 'additionalClassifications.description', 
            'status', 'resolutionType', 'resolution', 'satisfied', 'complaintID', 'cancellationReason']


    if field in value:
        type_fields = 'value'
    elif field in text:
        type_fields = 'text'

    return type_fields
                       

def get_delivery_region(region):
#cat     if region == u"місто Київ":
#cat         delivery_region = u"м.Київ"
#cat     elif region == u"м.Київ":
#cat         delivery_region = u"місто Київ"
#cat     elif region == u"Дніпропетровська область":
#cat         delivery_region = u"Днiпропетровська область"
#cat     elif region == u"Рівненська область":
#cat         delivery_region = u"Рiвненська область"
#cat     else: delivery_region = region
#cat     return delivery_region
     return region

def convert_float_to_string(number):
    return format(number, '.2f')

def convert_coordinates_to_string(number):
    return format(number)

def adapt_delivery_date(date):
    adapt_date = ''.join([date[:date.index('T') + 1], '00:00:00', date[date.index('+'):]])
    return adapt_date

def parse_date(date_str):
    date = datetime.strptime(date_str, "%d.%m.%Y %H:%M:%S")
    return TZ.localize(date).strftime('%Y-%m-%dT%H:%M:%S.%f%z')
#cat#cat    date = datetime.strptime(date_str, "%d.%m.%Y %H:%M:%S")
#cat#cat    return TZ.localize(date).strftime('%Y-%m-%dT%H:%M:%S.%f%z')
    
#cat#cat	date_str = datetime.strptime(date_str, "%d.%m.%Y %H:%M")
#cat#cat    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
#cat#cat                    date_str.microsecond)
#cat#cat    date = TZ.localize(date).isoformat()
#cat#cat	13.01.2018 17:26:25
#cat#cat    return date


def parse_item_date(date_str):
    date = datetime.strptime(date_str, "%d.%m.%Y %H:%M:%S")
    return TZ.localize(date).strftime('%Y-%m-%dT%H:%M:%S.%f%z')
#cat#cat    date_str = datetime.strptime(date_str, "%d.%m.%Y")
#cat#cat    date = datetime(date_str.year, date_str.month, date_str.day)
#cat#cat    date = TZ.localize(date).isoformat()
    return date


def convert_date_to_string(date):
    date = dateutil.parser.parse(date)
    date = date.strftime("%d.%m.%Y %H:%M")
    return date


def convert_item_date_to_string(date):
    date = dateutil.parser.parse(date)
    date = date.strftime("%d.%m.%Y %H:%M")
    return date


def parse_complaintPeriod_date(date_string):
    date_str = datetime.strptime(date_string, "%d.%m.%Y %H:%M")
    date_str -= timedelta(minutes=5)
    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
                    date_str.microsecond)
    date = TZ.localize(date).isoformat()
    return date

def parse_complaintPeriod_endDate(date_str):
#cat    if '-' in date_str:
#cat        date_str = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")
#cat    else:
#cat        date_str = datetime.strptime(date_str, "%d.%m.%Y %H:%M")
#cat    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
#cat                    date_str.microsecond)
#cat    date = TZ.localize(date).isoformat()
#catdatetime.strptime( "2009-11-12 23:18:53", "%Y-%m-%d %H:%M:%S" )
    date = TZ.localize(date_str).strftime('%Y-%m-%dT%H:%M:%S.%f%z')
    return date

	
def capitalize_first_letter(string):
    string = string.lower()
    string = string.capitalize()
    return string


def get_unit_name(name):
    value = {
#cat        u'штуки': u'\tшт.\t',
#cat        u'упаковка': u'\tупак.\t',
#cat         u'набір': u'\tнаб.\t',
#cat         u'кілограми': u'\tкг.\t'
    }
    value = value.get(name)
    if value:
        return value
    else:
        return name
#cat def get_unit_region(region):
#cat     value = {
#cat         u'Вінницька область': u'Вінницька',
#cat         u'Волинська область': u'Волинська',
#cat         u'Дніпропетровська область': u'Дніпропетровська',
#cat         u'Донецька область': u'Донецька',
#cat         u'Житомирська область': u'Житомирська',
#cat         u'Закарпатська область': u'Закарпатська',
#cat         u'Запорізька область': u'Запорізька',
#cat         u'Івано-Франківська область': u'Івано-Франківська',
#cat         u'місто Київ': u'Київ',
#cat         u'Київська область': u'Київська',
#cat         u'Кіровоградська область': u'Кіровоградська',
#cat         u'Луганська область': u'Луганська',
#cat         u'Львівська область': u'Львівська',
#cat         u'Миколаївська область': u'Миколаївська',
#cat         u'Одеська область': u'Одеська',
#cat         u'Полтавська область': u'Полтавська',
#cat         u'Рівненська область': u'Рівненська',
#cat         u'Севастополь область': u'Севастополь',
#cat         u'Сумська область': u'\Сумська',
#cat         u'Тернопільська область': u'\Тернопільська',
#cat         u'Харківська область': u'Харківська',
#cat         u'Херсонська область': u'Херсонська',
#cat         u'Хмельницька область': u'Хмельницька',
#cat         u'Черкаська область': u'Черкаська',
#cat         u'Чернігівська область': u'Чернігівська',
#cat         u'Чернівецька область': u'Чернівецька',
#cat         u'АР Крим область': u'АР Крим'
#cat     }
#cat     value = value.get(region)
#cat     if value:
#cat         return value
#cat     else:
#cat         return region

def convert_locality(name):
    string = name.upper()
    return string


def convert_status(tender_status):
    status = {
        u'Очікування пропозицій': u'active.tendering',
        u'Період аукціону': u'active.auction',
        u'Період уточнень': u'active.enquiries',
        u'Перед-кваліфікаційний період': u'active.pre-qualification',
        u'Блокування перед аукціоном': u'active.pre-qualification.stand-still'
    }
    return status[tender_status]


def get_claim_status(claim_status, test_name):
    status = {
        u'Вимога': 'claim',
        u'Розглянуто': 'answered',
        u'Вирішена': 'resolved',
        u'Відхилено': 'cancelled'
    }
    status_resolved = {
        u'Розглянуто': 'resolved',
        u'Вирішена': 'resolved'
    }
    pending_status = {
        u'Обробляється': 'pending'
    }
    if u'підтвердити задоволення вимоги' in test_name or 'resolved' in test_name:
        value = status_resolved[claim_status]
    elif u"Відображення статусу 'pending'" in test_name:
        value = pending_status[claim_status]
    else:
        value = status[claim_status]
    return value


def get_resolution_type(resolution):
    type = {
        u'Вирішено': 'resolved'
    }
    return type[resolution]


def convert_satisfied(value):
    if value == u'Так':
        satisfied = True
    else:
        satisfied = False
    return satisfied


def get_unit(field,unit_data):
    unit = unit_data.split()
    unit_value = {
        'unit.code': unit[0],
        'unit.name': unit[1]
    }
    return unit_value[field]


def convert_type_tender(key):
    type_tender = {
        u'Відкриті торги': 'aboveThresholdUA',
        u'Відкриті торги з публікацією англ.мовою': 'aboveThresholdEU',
        u'Переговорна процедура': 'reporting'
    }
    return type_tender[key]


def convert_data_lot(key):
    data_lot = {
        u'грн.': 'UAH',
        'UAH': 'UAH'
    }
    return data_lot[key]


def convert_data_feature(key):
    data_feature = {
        u'Закупівлі': 'tenderer',
        u'Лоту': 'lot',
        u'Предмету лоту': 'item'
    }
    return data_feature[key]


def convert_complaintID(tender_uaid, type_complaint):
    if type_complaint == 'tender':
        value = tender_uaid + '.b1'
    elif type_complaint == 'lot':
        value = tender_uaid + '.b2'
    return value


def get_pos(featureOf):
    if featureOf == u'Закупівлі':
        position = 1
    elif featureOf == u'Лоту':
        position = 2
    elif featureOf == u'Предмету лоту':
        position = 1
    return position


def get_value_feature(value):
    value = value * 100
    value = str(int(value)) + '%'
    return value


def get_feature_xpath(field_name, feature_id):
    xpath = {
        'title': "//*[contains(@value, '" +feature_id+ "')]",
        'description': "//*[contains(@data-prozorro-title-id, '" +feature_id+ "') and contains(@name,'feature_description')]",
        'featureOf': "//*[contains(@data-prozorro-title-id, '" +feature_id+ "') and contains(@name,'featureOf')]"
    }
    return xpath[field_name]


def convert_bid_status(value):
    status = {
        u'Недійсна пропозиція': 'invalid'
    }
    return status[value]


def convert_float_to_string(number):

    return '{0:.2f}'.format(float(number))
	

def convert_string_to_float(number):

    return float(number)
#cat    return float("{0:.2f}".format(number))	


def _is_visible(self, locator):
    element = self._element_find(locator, True, False)
    if element is not None:
        return element.is_displayed()
    return None
	
def get_upload_file_path():
    return os.path.join(os.getcwd(), 'src/robot_tests.broker.ukrtender/testFileForUpload.txt')	
	
#catdef copyfile_qual(source, dest):
#cat	shutil.copy(source,dest)
#cat    return None
#import shutil
#shutil.copy('/homed-0a7c4b9edolorumossr7P.doc/cat/robot_tests/test_output/','src/robot_tests.broker.ukrtender/')

def convert_cause_type(key):
    cause_type = {
        '1': 'artContestIP',
        '2': 'noCompetition',
        '4': 'twiceUnsuccessful',
        '5': 'additionalPurchase',
        '6': 'additionalConstruction',
        '7': 'stateLegalServices',
    }
    return cause_type[key]

def convert_cause_type2(key):
    cause_type = {
        'artContestIP': 'cт. 35, п. 1 Закупівля творів мистецтва',
        'noCompetition': 'cт. 35, п. 2 Відсутність конкуренції',
        'twiceUnsuccessful': 'ст. 35, п. 4 Закупівля проведена попередньо двічі невдало',
        'additionalPurchase': 'cт. 35, п. 5 Додаткова закупівля',
        'additionalConstruction': 'cт. 35, п. 6 Додаткові будівельні роботи',
        'stateLegalServices': 'cт. 35, п. 7 Закупівля юридичних послуг',
    }
    return cause_type[key]	

def conc_class(des, id):
#,tcn
    data = des + ' - ' + id
    return data	
	
def conc_class3(des, id, n):
#,tcn
    data = des + ' (' + id + ' ' + n + ')'
    return data		

def split_str(string):
#,tcn
#    start = string.find('tender[items][') + 1
#    string = string.find('][lot]', start)
#    end = s.find('][lot]', start)
#    string = string.capitalize()
#    return string
    parts = string.split('][', 2)
    return parts[1]

def split_str1(string):
    parts = string.split(': ', 2)
    return parts[1]

def split_complaint(string):
    parts = string.split('complaintid-', 2)
    return parts[1]
	
def parse_contract_date(date_string):
    return date_string.replace('+','.000000+')
#cat    date_str = datetime.strptime(date_string, "%Y-%m-%d %H:%M:%S")
#cat    date_str -= timedelta(minutes=5)
#cat    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second, date_str.microsecond)
#cat    date = TZ.localize(date).isoformat()
#	date = date_str.replace('+','.000000+')
#cat    if '-' in date_str:
#cat        date_str = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")
#cat    else:
#cat        date_str = datetime.strptime(date_str, "%d.%m.%Y %H:%M")
#cat    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
#cat                    date_str.microsecond)
#cat    date = TZ.localize(date).isoformat()
#catdatetime.strptime( "2018-07-18T03:08:36+03:00", "%Y-%m-%d %H:%M:%S" )
#cat    return date

def convert_time(date):
    date = datetime.strptime(date, "%d.%m.%Y %H:%M:%S")
#cat    return TZ.localize(date).strftime('%Y-%m-%dT%H:%M:%S.%f%z')
#cat  %f - миллисек %z +3000
    return TZ.localize(date).strftime('%Y-%m-%dT%H:%M:%S')

def data_zone(des):
#,tcn
    data = des + '+03:00'
    return data		
	
def get_value_minimalStepPercentage(value):
    value = value / 100
    return value

def set_value_minimalStepPercentage(value):
    value = value * 100
    return value	
	
def convert_esco__float_to_string(number):

    return '{0:.5f}'.format(float(number))

def convert_date_to_string_contr(date):
    date = dateutil.parser.parse(date)
    date = date.strftime("%d.%m.%Y %H:%M:%S")
    return date
	