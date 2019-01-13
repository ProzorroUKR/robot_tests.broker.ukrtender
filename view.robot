*** Settings ***
Library  Selenium2Library
Library  String
Library  DateTime
Library  ukrtender_service.py
Resource  ukrtender.robot

*** Keywords ***

Отримати інформацію про title
  ${return_value}=   Get Value  xpath=//*[@name="tender[name]"]
  [return]  ${return_value}

Отримати інформацію про title_en
  ${return_value}=   Get Value  xpath=//*[@name="tender[name_en]"]
  [return]  ${return_value}

Отримати інформацію про title_ru
  ${return_value}=   Get Value  xpath=//*[@name="tender[name_ru]"]
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Get Value  xpath=//*[@name="tender[description]"]
  [return]  ${return_value}

Отримати інформацію про description_en
  ${return_value}=   Get Value  xpath=//*[@name="tender[description_en]"]
  [return]  ${return_value}

Отримати інформацію про description_ru
  ${return_value}=   Get Value  xpath=//*[@name="tender[description_ru]"]
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${value}=    Run Keyword If    '${mode}' == 'belowThreshold'    Get Value    xpath=//*[@name="tender[amount]"]
  ...          ELSE IF           '${mode}' != 'belowThreshold'    Get Value    xpath=//*[@name="tender[amount]"]
  ${return_value}=   convert_string_to_float  ${value}
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${type_tender}=    Get Text            xpath=//*[@name='tender[procedure_type]']
  ${value_below}=  Get Value    xpath=//*[@name='tender[rate_amount]']
  ${value_open}=  Get Value           xpath=//*[@name='tender[rate_amount]']
  ${return_value}=    Set Variable If    '${type_tender}' == 'Допорогові закупівлі'    ${value_open}    ${value_below}
  ${return_value}=  ukrtender_service.convert_float_to_string2    ${return_value}
  ${return_value}=  Convert To Number    ${return_value}    2
  [return]  ${return_value}

Отримати інформацію про procurementMethodType
  ${return_value}=    Get Value    xpath=//*[@name='tender[procedure_type]']
  [return]  ${return_value}

Отримати інформацію про value.currency
  ${return_value}=  Get Text  xpath=//*[@name='tender[currency]']
  ${return_value}=  Convert To String  UAH
  [return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=  Convert To Boolean  True
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=  Get Value           xpath=//*[@name="tender[specification_period_start]"]
  Log Many  CAT777 ${return_value}
  ${return_value}=  parse_date  ${return_value}
  Log Many  CAT888 ${return_value}
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  ${type_tender}=    Get Value           xpath=//*[@name='tender[procedure_type]']
  ${value_open}=    Get Value    xpath=//*[@name="tender[specification_period]"]
  ${value_below}=    Get Value    xpath=//*[@name="tender[specification_period]"]
  ${return_value}=    Set Variable If    '${type_tender}' != 'belowThreshold'    ${value_open}
  ...                                '${type_tender}' == 'belowThreshold'    ${value_below}
  ${return_value}=  parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про complaintPeriod.endDate
  ${return_value}=    Get Value    xpath=//*[@name='tender[complaint_enddate]']
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${type_tender}=    Get Value          xpath=//*[@name='tender[procedure_type]']
  ${value_open}=    Get Value           xpath=//*[@name='tender[reception_from]']
  ${value_below}=  Get Value           xpath=//*[@name='tender[reception_from]']
  ${return_value}=    Set Variable If    '${type_tender}' != 'belowThreshold'    ${value_open}
  ...                                '${type_tender}' == 'belowThreshold'    ${value_below}
  ${return_value}=  parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=  Get Value           xpath=//*[@name='tender[reception_to]']
  ${return_value}=  parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=  Get Value           xpath=//*[@name="tender[procuringentity][legalname]"]
  [return]  ${return_value}

Отримати інформацію про tenderID
  ${return_value}=  Get Text           xpath=//*[@id="tender-information-external-id"]
  [return]  ${return_value}

Отримати інформацію про status
  Log Many  CAT777 ${TEST_NAME}
  Run Keyword If    '${TEST_NAME}' == 'Неможливість завантажити документ першим учасником після закінчення прийому пропозицій'  Wait Until Keyword Succeeds  480 s  20 s  subkeywords.Wait For EndEnquire
  Run Keyword If    '${TEST_NAME}' == 'Неможливість завантажити документ другим учасником після закінчення прийому пропозицій'  Wait Until Keyword Succeeds  480 s  20 s  subkeywords.Wait For EndEnquire
  Run Keyword If    '${TEST_NAME}' == 'Неможливість задати запитання на тендер після закінчення періоду прийому пропозицій'    Wait Until Keyword Succeeds    480 s    20 s    subkeywords.Wait For EndEnquire
  Run Keyword If    '${TEST_NAME}' == 'Неможливість задати запитання на тендер після закінчення періоду уточнень'    Sleep  30
  Run Keyword If    '${TEST_NAME}' == 'Неможливість задати запитання на тендер після закінчення періоду уточнень'    Reload Page
  Run Keyword If    '${TEST_NAME}' == 'Можливість вичитати посилання на аукціон для глядача'    Reload Page
  #Run Keyword If    '${TEST_NAME}' == 'Неможливість задати запитання на тендер після закінчення періоду уточнень'  Wait Until Keyword Succeeds  480 s  20 s  subkeywords.Wait For EndEnquire
  Run Keyword If    '${TEST_NAME}' == 'Можливість подати пропозицію першим учасником'      Wait Until Keyword Succeeds    480 s    20 s    subkeywords.Wait For TenderPeriod
  Run Keyword If    '${TEST_NAME}' == 'Можливість подати пропозицію другим учасником'      Wait Until Keyword Succeeds    480 s    20 s    subkeywords.Wait For TenderPeriod
  Run Keyword If    '${TEST_NAME}' == 'Відображення дати закінчення періоду блокування перед початком аукціону'    Wait Until Keyword Succeeds    80 s    20 s    subkeywords.Wait For AuctionPeriod
  Run Keyword If    '${TEST_NAME}' == 'Можливість підтвердити першу пропозицію кваліфікації'    Wait Until Keyword Succeeds    80 s    20 s    subkeywords.Wait For PreQualificationPeriod
  Run Keyword If    '${TEST_NAME}' == 'Можливість підтвердити другу пропозицію кваліфікації'    Wait Until Keyword Succeeds    80 s    20 s    subkeywords.Wait For PreQualificationPeriod
  Run Keyword If    '${TEST_NAME}' == 'Можливість дочекатися завершення роботи мосту'    Wait Until Keyword Succeeds    80 s    20 s    subkeywords.Wait For CompletePeriod
#cat  Run Keyword If    '${TEST_NAME}' == 'Можливість дочекатися початку періоду очікування'    Wait Until Keyword Succeeds    600 s    20 s    subkeywords.Wait For PreQualificationsStandPeriod
  Run Keyword If    '${TEST_NAME}' == 'Можливість дочекатися початку періоду очікування'    Wait Until Keyword Succeeds    600 s    20 s    subkeywords.Wait For ActiveStage2Pending
  Run Keyword If    '${TEST_NAME}' == 'Можливість перевести тендер в статус очікування обробки мостом'    Wait Until Keyword Succeeds    600 s    20 s    subkeywords.Wait For ActiveStage2Waiting
  Run Keyword If    '${TEST_NAME}' == 'Неможливість відповісти на запитання до тендера після завершення періоду відповідей'    Sleep  300
  Run Keyword If    '${TEST_NAME}' == 'Відображення дати початку аукціону'    Reload Page
  Run Keyword If    '${TEST_NAME}' == 'Можливість дочекатись дати закінчення прийому пропозицій' and '${SUITE NAME}' == 'Tests Files.Complaints'   Wait Until Keyword Succeeds    800 s    20 s    subkeywords.Wait For NotTenderPeriod
  Run Keyword If    '${TEST_NAME}' == 'Можливість дочекатись дати початку періоду кваліфікації' and '${SUITE NAME}' == 'Tests Files.Complaints'   Wait Until Keyword Succeeds    800 s    20 s    subkeywords.Wait For QualificationsStandPeriod
  ${return_value}=    Get Value    xpath=//*[@name='tender[status]']
  Log Many  CAT888 ${return_value}
  [return]  ${return_value}


Отримати інформацію про items[0].description
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][item_name]"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.startDate
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][reception_from]"]
  ${return_value}=  ukrtender_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][reception_to]"]
  ${return_value}=  ukrtender_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][latitude]"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][longitude]"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][country]"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName_en
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][country_en]"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName_ru
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][country_ru]"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][post_index]"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][region]"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][locality]"]
  ${return_value}=    capitalize_first_letter    ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][address]"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.scheme
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][dk_021_2015][scheme]"]
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][dk_021_2015][id]"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.description
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][dk_021_2015][title]"]
#cat  Log Many  CAT888 ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  ${return_value}=  Get Text           xpath=//*[@name="tender[items][0][dk_moz_mnn][scheme]"]
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][dk_moz_mnn][id]"]
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=  Get Text           xpath=//span[contains(.,'INN: ')]
  ${return_value}=  split_str1  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=  Get Value                     xpath=//*[@name="tender[items][0][unit_name]"]
  ${return_value}=  adapt_data.adapt_unit_name    ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][unit]"]
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].quantity
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][0][item_quantity]"]
  ${return_value}=  Convert To Number  ${return_value}
  [return]  ${return_value}

#item 2
Отримати інформацію про items[1].description
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][item_name]"]
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryDate.startDate
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][reception_from]"]
  ${return_value}=  ukrtender_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryDate.endDate
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][reception_to]"]
  ${return_value}=  ukrtender_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryLocation.latitude
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][latitude]"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[1].deliveryLocation.longitude
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][longitude]"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[1].deliveryAddress.countryName
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][country]"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.countryName_en
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][country_en]"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.countryName_ru
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][country_ru]"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.postalCode
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][post_index]"]
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.region
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][region]"]
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.locality
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][locality]"]
  ${return_value}=    capitalize_first_letter    ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].deliveryAddress.streetAddress
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][address]"]
  [return]  ${return_value}

Отримати інформацію про items[1].classification.scheme
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][dk_021_2015][scheme]"]
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].classification.id
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][dk_021_2015][id]"]
  [return]  ${return_value}

Отримати інформацію про items[1].classification.description
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][dk_021_2015][title]"]
  [return]  ${return_value}

Отримати інформацію про items[1].additionalClassifications[0].scheme
  ${return_value}=  Get Text           xpath=(//*[@id="mForm:bidItem_0:item0"]/tbody/tr[3]/td[3]/label)[2]
  ${return_value}=  Get Substring  ${return_value}  36  40
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].additionalClassifications[0].id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:cDkpp_input"]
  [return]  ${return_value}

Отримати інформацію про items[1].additionalClassifications[0].description
  ${return_value}=  Get Text           xpath=//*[@name="item_scheme"]
  ${return_value}=  Strip String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].unit.name
  ${return_value}=  Get Value                     xpath=//*[@name="tender[items][1][unit_name]"]
  ${return_value}=  adapt_data.adapt_unit_name    ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].unit.code
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][unit]"]
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[1].quantity
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][1][item_quantity]"]
  ${return_value}=  Convert To Number  ${return_value}
  [return]  ${return_value}

#item 3
Отримати інформацію про items[2].description
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][item_name]"]
  [return]  ${return_value}

Отримати інформацію про items[2].deliveryDate.startDate
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][reception_from]"]
  ${return_value}=  ukrtender_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].deliveryDate.endDate
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][reception_to]"]
  ${return_value}=  ukrtender_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].deliveryLocation.latitude
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][latitude]"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[2].deliveryLocation.longitude
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][longitude]"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[2].deliveryAddress.countryName
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][country]"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].deliveryAddress.countryName_en
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][country_en]"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].deliveryAddress.countryName_ru
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][country_ru]"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].deliveryAddress.postalCode
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][post_index]"]
  [return]  ${return_value}

Отримати інформацію про items[2].deliveryAddress.region
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][region]"]
  [return]  ${return_value}

Отримати інформацію про items[2].deliveryAddress.locality
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][locality]"]
  ${return_value}=    capitalize_first_letter    ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].deliveryAddress.streetAddress
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][address]"]
  [return]  ${return_value}

Отримати інформацію про items[2].classification.scheme
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][dk_021_2015][scheme]"]
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].classification.id
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][dk_021_2015][id]"]
  [return]  ${return_value}

Отримати інформацію про items[2].classification.description
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][dk_021_2015][title]"]
  [return]  ${return_value}

Отримати інформацію про items[2].additionalClassifications[0].scheme
  ${return_value}=  Get Text           xpath=(//*[@id="mForm:bidItem_0:item0"]/tbody/tr[3]/td[3]/label)[2]
  ${return_value}=  Get Substring  ${return_value}  36  40
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].additionalClassifications[0].id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:cDkpp_input"]
  [return]  ${return_value}

Отримати інформацію про items[2].additionalClassifications[0].description
  ${return_value}=  Get Text           xpath=//*[@name="item_scheme"]
  ${return_value}=  Strip String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].unit.name
  ${return_value}=  Get Value                     xpath=//*[@name="tender[items][2][unit_name]"]
  ${return_value}=  adapt_data.adapt_unit_name    ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].unit.code
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][unit]"]
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[2].quantity
  ${return_value}=  Get Value           xpath=//*[@name="tender[items][2][item_quantity]"]
  ${return_value}=  Convert To Number  ${return_value}
  [return]  ${return_value}
  
  
Отримати інформацію про tender_document.title
  ${return_value}=  Get Value           xpath=//*[@name='tender[documents]']
  [return]  ${return_value}

Отримати інформацію про questions[0].title
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  :FOR    ${INDEX}    IN RANGE    1    45
  \  ${question_is_visible}  Run Keyword And Return Status  Element Should Be Visible  xpath=//h3[@id="tender-question-list-title-0"]
  \  Exit For Loop If  ${question_is_visible}
  \  Sleep  5
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//a[@href="#tabs_desc_407_2"]
  Wait Until Keyword Succeeds  10 x  5 s  Run Keywords
  ...  Reload Page
  ...  AND  Дочекатися І Клікнути                xpath=//a[@href="#tabs_desc_407_2"]
  ...  AND  Element Should Be Visible  xpath=//h3[@id="tender-question-list-title-0"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//h3[@id="tender-question-list-title-0"]
  [return]  ${return_value}

Отримати інформацію про questions[0].description
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//span[@id="tender-question-list-description-0"]
  [return]  ${return_value}

Отримати інформацію про questions[0].date
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//span[@id="tender-question-list-questiondate-0"]
  [return]  ${return_value}

Отримати інформацію про questions[0].answer
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//span[@id="tender-question-list-answer-0"]
  [return]  ${return_value}

Отримати інформацію про questions[1].title
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//h3[@id="tender-question-list-title-1"]
  [return]  ${return_value}

Отримати інформацію про questions[1].description
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  Дочекатися І Клікнути    xpath=//h3[@id='tender-question-list-title-1']
  ${return_value}=  Get Text  xpath=//span[@id='tender-question-list-description-1']
  [return]  ${return_value}

Отримати інформацію про questions[1].date
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  Дочекатися І Клікнути    xpath=//h3[@id='tender-question-list-title-1']
  ${return_value}=  Get Text  xpath=//span[@id='tender-question-list-questiondate-1']
  [return]  ${return_value}

Отримати інформацію про questions[1].answer
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  Дочекатися І Клікнути    xpath=//h3[@id='tender-question-list-title-1']
  ${return_value}=  Get Text  xpath=//span[@id="tender-question-list-answer-1"]
  [return]  ${return_value}
  
Отримати інформацію про questions[2].title
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  Дочекатися І Клікнути    xpath=//h3[@id='tender-question-list-title-2']
  ${return_value}=  Get Text  xpath=//h3[@id="tender-question-list-title-2"]
  [return]  ${return_value}

Отримати інформацію про questions[2].description
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  Дочекатися І Клікнути    xpath=//h3[@id='tender-question-list-title-2']
  ${return_value}=  Get Text  xpath=//span[@id="tender-question-list-description-2"]
  [return]  ${return_value}

Отримати інформацію про questions[2].date
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  Дочекатися І Клікнути    xpath=//h3[@id='tender-question-list-title-2']
  ${return_value}=  Get Text  xpath=//span[@id="tender-question-list-questiondate-2"]
  [return]  ${return_value}

Отримати інформацію про questions[2].answer
  Sleep  5
  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Sleep  5
  Дочекатися І Клікнути    xpath=//h3[@id='tender-question-list-title-2']
  ${return_value}=  Get Text  xpath=//span[@id="tender-question-list-answer-2"]
  [return]  ${return_value}

Отримати інформацію про awards[0].complaintPeriod.endDate
  Log Many  CAT888 Відображення закінчення періоду подачі скарг на пропозицію
  Run Keyword If  '${TEST_NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Reload Page
  Run Keyword If  '${TEST NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Подивитись на учасників
#  Подивитись на учасників
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Оскарження результатів кваліфікації')]
  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-1"]
  :FOR    ${INDEX}    IN RANGE    1    30
  \  Run Keyword If    '${complaintPeriod}' != ''    Exit For Loop
  \  Sleep  5
  \  Reload Page
  \  Run Keyword If  '${TEST NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Подивитись на учасників
  \  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-1"]
#cat  ${return_value}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-1"]
  ${return_value}    Set Variable  ${complaintPeriod}
  Run Keyword If  '${MODE}' in 'openua' and '${SUITE NAME}' == 'Tests Files.Complaints'  Дочекатися І Клікнути   xpath=//button[@id='edit-tender-award-supplier-cancel']
  Run Keyword If  '${MODE}' in "reporting negotiation openua_defense"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  [return]  ${return_value}

Отримати інформацію про awards[1].complaintPeriod.endDate
  Log Many  CAT888 Відображення закінчення періоду подачі скарг на пропозицію
  Run Keyword If  '${TEST_NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Reload Page
  Run Keyword If  '${TEST NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Подивитись на учасників
#  Подивитись на учасників
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Оскарження результатів кваліфікації')]

#cat  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-2"]
#cat  Run Keyword If   '${complaintPeriod}' == ''  Wait Until Keyword Succeeds
#cat  ...  3x
#cat  ...  AND  10s
#cat  ...  AND  Reload Page
#cat  ...  AND  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
#cat  ...  AND  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-2"]
  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-2"]
  :FOR    ${INDEX}    IN RANGE    1    30
  \  Run Keyword If    '${complaintPeriod}' != ''    Exit For Loop
  \  Sleep  5
  \  Reload Page
  \  Run Keyword If  '${TEST NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Подивитись на учасників
  \  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-2"]
  
#cat  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-2"]
  ${return_value}    Set Variable  ${complaintPeriod}
  Run Keyword If  '${MODE}' in "reporting negotiation openua openeu"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  [return]  ${return_value}

Отримати інформацію про awards[2].complaintPeriod.endDate
  Log Many  CAT888 Відображення закінчення періоду подачі скарг на пропозицію
  Run Keyword If  '${TEST_NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Reload Page
  Run Keyword If  '${TEST NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Подивитись на учасників
#  Подивитись на учасників
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Оскарження результатів кваліфікації')]
  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-3"]
  :FOR    ${INDEX}    IN RANGE    1    30
  \  Run Keyword If    '${complaintPeriod}' != ''    Exit For Loop
  \  Sleep  5
  \  Reload Page
  \  Run Keyword If  '${TEST NAME}'=='Відображення закінчення періоду подачі скарг на пропозицію'  Подивитись на учасників
  \  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-3"]
#cat  ${complaintPeriod}=  Get Value  xpath=//*[@id="edit-tender-award-complaintperiod-enddate-3"]
  ${return_value}    Set Variable  ${complaintPeriod}
  Run Keyword If  '${MODE}' in "reporting negotiation openua openeu"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  [return]  ${return_value}

Подивитись на учасників
  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  Run Keyword If  '${MODE}' in 'reporting negotiation openua_defense'  Visible edit-tender-award-item-supplier  a[@id='edit-tender-award-item-supplier-1']
  Run Keyword If  '${MODE}' in 'reporting negotiation openua_defense'  Дочекатися І Клікнути                       xpath=//a[@id='edit-tender-award-item-supplier-1']
  Run Keyword If  '${MODE}' in 'openua openeu' and '${SUITE NAME}' != 'Tests Files.Complaints'  Visible edit-tender-award-item-supplier  a[@id='edit-tender-award-item-supplier-2']
  Run Keyword If  '${MODE}' in 'openua openeu' and '${SUITE NAME}' != 'Tests Files.Complaints'  Дочекатися І Клікнути                       xpath=//a[@id='edit-tender-award-item-supplier-2']
  Run Keyword If  '${MODE}' in 'openua' and '${SUITE NAME}' == 'Tests Files.Complaints'  Дочекатися І Клікнути                       xpath=//a[@id='edit-tender-award-item-supplier-1']

  
Отримати інформацію про causeDescription
  ${return_value}  Get Value  xpath=//*[@name="tender[negotiation][prove]"]
  [return]  ${return_value}

Отримати інформацію про cause
  ${return_value}  Get Value  xpath=//*[@name="tender[negotiation][type]"]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.name
  ${return_value}  Get Value  name=tender[procuringentity][name]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.telephone
  ${return_value}  Get Value  name=tender[procuringentity][phone]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.contactPoint.url
  ${return_value}  Get Value  name=tender[procuringentity][url]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.identifier.legalName
  ${return_value}  Get Value  name=tender[procuringentity][legalname]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.countryName
  ${return_value}  Get Value  name=tender[procuringentity][country]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.locality
  ${return_value}  Get Value  name=tender[procuringentity][locality]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.postalCode
  ${return_value}  Get Value  name=tender[procuringentity][postalcode]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.region
  ${return_value}  Get Value  name=tender[procuringentity][region]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.address.streetAddress
  ${return_value}  Get Value  name=tender[procuringentity][address]
  [return]  ${return_value}

Отримати інформацію про procuringEntity.identifier.scheme
  ${country}  Get Value  name=tender[procuringentity][country]
  ${return_value}  Set Variable If  '${country}'=='Україна'  UA-EDR  other
  [return]  ${return_value}

Отримати інформацію про procuringEntity.identifier.id
  ${return_value}  Get Value  name=tender[procuringentity][identifier_id]
  [return]  ${return_value}

Отримати інформацію про documents[0].title
  ${return_value}  Get Value  xpath=//*[@name='tender[documents]']
  [return]  ${return_value}

Отримати інформацію про awards[0].documents[0].title
  Подивитись на учасників
  Wait Until Element Is Visible  xpath=//*[@id='edit-tender-award-supplier-document-title-0']   90
  ${title}  Get Text  id=edit-tender-award-supplier-document-title-0
  [return]  ${title}

Отримати інформацію про awards[0].status
#cat  Подивитись на учасників
  ${status}  Get Text  id=edit-tender-award-supplier-status
  ${return_value}  Set Variable If  '${status}'=='переможець'  active  other status
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.telephone
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-telephone
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.name
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-name
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].contactPoint.email
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-email
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.countryName
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-country
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.locality
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-locality
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.postalCode
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-postalcode
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.region
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-region
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].address.streetAddress
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-street
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].identifier.scheme
#cat  Подивитись на учасників
  ${country}  Get Text  id=edit-tender-award-supplier-contact-country
  ${return_value}  Set Variable If  '${country}'=='Україна'  UA-EDR  other
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].identifier.legalName
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-identifier-legalName
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].identifier.id
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-identifier-id
  [return]  ${return_value}

Отримати інформацію про awards[0].suppliers[0].name
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-identifier-legalName
  [return]  ${return_value}

Отримати інформацію про awards[0].value.valueAddedTaxIncluded
#cat  Подивитись на учасників
  ${vat}  Get Text  id=edit-tender-award-value-valueAddedTaxIncluded
  ${return_value}  Set Variable If  '${vat}'=='1'  ${TRUE}  ${FALSE}
  [return]  ${return_value}

Отримати інформацію про awards[0].value.currency
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-value-currency
  [return]  ${return_value}

Отримати інформацію про awards[0].value.amount
#cat  Подивитись на учасників
  Select award-value-amount  a[@id='edit-tender-award-item-supplier-1']
#cat  :FOR    ${INDEX}    IN RANGE    1    15
#cat  \  ${contract_value_is_visible}  Run Keyword And Return Status  Element Should Be Visible  xpath=//*[@id='edit-tender-award-value-amount']
#cat  \  Exit For Loop If  ${contract_value_is_visible}
#cat  \  Sleep  15
#cat  \  Reload Page
#cat  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
#cat  \  Дочекатися І Клікнути                       xpath=//a[@id='edit-tender-award-item-supplier-1']
  ${value}  Get Text  id=edit-tender-award-value-amount
  ${return_value}  convert_string_to_float   ${value}
  Log Many  CAT777 ${return_value} До первой отмены
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Log Many  CAT777 ${return_value} После первой отмены
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  Log Many  CAT777 ${return_value} После второй отмены
  [return]  ${return_value}

Отримати інформацію про awards[1].documents[0].title
  Подивитись на учасників
  Wait Until Element Is Visible  xpath=//*[@id='edit-tender-award-supplier-document-title-0']   90
  ${title}  Get Text  id=edit-tender-award-supplier-document-title-0
  [return]  ${title}

Отримати інформацію про awards[1].status
#cat  Подивитись на учасників
  ${status}  Get Text  id=edit-tender-award-supplier-status
  ${return_value}  Set Variable If  '${status}'=='переможець'  active  other status
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].contactPoint.telephone
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-telephone
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].contactPoint.name
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-name
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].contactPoint.email
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-email
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].address.countryName
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-country
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].address.locality
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-locality
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].address.postalCode
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-postalcode
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].address.region
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-region
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].address.streetAddress
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-contact-street
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].identifier.scheme
#cat  Подивитись на учасників
  ${country}  Get Text  id=edit-tender-award-supplier-contact-country
  ${return_value}  Set Variable If  '${country}'=='Україна'  UA-EDR  other
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].identifier.legalName
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-identifier-legalName
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].identifier.id
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-identifier-id
  [return]  ${return_value}

Отримати інформацію про awards[1].suppliers[0].name
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-supplier-identifier-legalName
  [return]  ${return_value}

Отримати інформацію про awards[1].value.valueAddedTaxIncluded
#cat  Подивитись на учасників
  ${vat}  Get Text  id=edit-tender-award-value-valueAddedTaxIncluded
  ${return_value}  Set Variable If  '${vat}'=='1'  ${TRUE}  ${FALSE}
  [return]  ${return_value}

Отримати інформацію про awards[1].value.currency
#cat  Подивитись на учасників
  ${return_value}  Get Text  id=edit-tender-award-value-currency
  [return]  ${return_value}

Отримати інформацію про awards[1].value.amount
#cat  Подивитись на учасників
  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue'  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
#cat  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue'  Дочекатися І Клікнути                       xpath=//a[@id='edit-tender-award-item-supplier-2']
  Select award-value-amount  a[@id='edit-tender-award-item-supplier-2']
  ${value}  Get Text  id=edit-tender-award-value-amount
  ${return_value}  convert_string_to_float   ${value}
  Log Many  CAT777 ${return_value} До первой отмены
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Log Many  CAT777 ${return_value} После первой отмены
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  Log Many  CAT777 ${return_value} После второй отмены
  [return]  ${return_value}

Отримати інформацію про awards[2].value.amount
#cat  Подивитись на учасників
  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue open_esco'  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
#cat  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue open_esco'  Дочекатися І Клікнути                       xpath=//a[@id='edit-tender-award-item-supplier-3']
  Select award-value-amount  a[@id='edit-tender-award-item-supplier-3']
  ${value}  Get Text  id=edit-tender-award-value-amount
  ${return_value}  convert_string_to_float   ${value}
  Log Many  CAT777 ${return_value} До первой отмены
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Log Many  CAT777 ${return_value} После первой отмены
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  Log Many  CAT777 ${return_value} После второй отмены
  [return]  ${return_value}

Отримати інформацію про contracts[0].value.amount
  Set Global Variable  ${contract_visible}   contract_visible
  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="0"]
  :FOR    ${INDEX}    IN RANGE    1    15
  \  ${contract_value_is_visible}  Run Keyword And Return Status  Element Should Be Visible  xpath=//span[@id='edit-tender-dialog-contract-amount']
  \  Exit For Loop If  ${contract_value_is_visible}
  \  Sleep  15
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="0"]
  :FOR    ${INDEX}    IN RANGE    1    8
  \  Sleep  5
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="0"]
  ${value}=  Get Element Attribute   xpath=//span[@id="edit-tender-dialog-contract-amount"]@data-value
  Log Many  CAT777 value= ${value} 
  ${return_value}  convert_string_to_float   ${value}
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-cancel']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  [return]  ${return_value}
  
Отримати інформацію про contracts[1].value.amount
  Set Global Variable  ${contract_visible}   contract_visible
  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="1"]
  ${value_old}=  Get Element Attribute   xpath=//span[@id="edit-tender-dialog-contract-amount"]@data-value
  ${value}=  Очікування зміни відредагованої вартості угоди   ${value_old}   1
  Log Many  CAT777 value= ${value} 
  ${return_value}  convert_string_to_float   ${value}
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-cancel']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  [return]  ${return_value}

Отримати інформацію про contracts[0].status
  :FOR    ${INDEX}    IN RANGE    1    15
  \  Sleep  5
  \  Reload Page
  Подивитись на учасників
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Контракт')]
  Sleep  10
  ${return_value}  Get Value  id=edit-tender-award-contract-status-1
  Run Keyword If  '${MODE}' in "reporting negotiation openua_defense"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  [return]  ${return_value}

Отримати інформацію про contracts[1].status
  :FOR    ${INDEX}    IN RANGE    1    15
  \  Sleep  5
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Контракт')]
  ${contract_num}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  3
  ...  ELSE  Set Variable  2
  ${return_value}  Get Value  id=edit-tender-award-contract-status-${contract_num}
  Run Keyword If  '${MODE}' in "reporting negotiation"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  [return]  ${return_value}
  
Отримати інформацію про contracts[0].dateSigned
  Подивитись на учасників
  Capture Page Screenshot
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Контракт') and @data-index="0"]
  Run Keyword If  '${MODE}' in "openua_defense"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Capture Page Screenshot
  Run Keyword If  '${MODE}' in "openua_defense"    Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="0"]
#cat  Run Keyword If  '${MODE}' in "openua_defense"   Sleep  3 
  Capture Page Screenshot
  Wait Until Element Is Visible  xpath=//span[@id='edit-tender-dialog-contract-signed-date']   10
  ${contract_signed_date}=  Get Value  name=contract[signed_date]
  Capture Page Screenshot
  :FOR    ${INDEX}    IN RANGE    1    30
  \  Run Keyword If    '${contract_signed_date}' != ''    Exit For Loop
  \  Sleep  5
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="0"]
  \  ${contract_signed_date}=  Get Value  name=contract[signed_date]
  Capture Page Screenshot
  ${return_value}  Get Value  name=contract[signed_date]
  Run Keyword If  '${MODE}' in "reporting negotiation openua openeu openua_defense"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  Capture Page Screenshot
  Run Keyword If  '${MODE}' not in "openua_defense"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-cancel']
  [return]  ${return_value}

Отримати інформацію про contracts[1].dateSigned
  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  Run Keyword If  '${MODE}' in 'open_esco'  Set Global Variable  ${contract_visible}   contract_visible
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Контракт')]
  ${contract_num}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  2
  ...  ELSE  Set Variable  1
  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${contract_num}"]
  ${contract_signed_date}=  Get Value  name=contract[signed_date]
  :FOR    ${INDEX}    IN RANGE    1    30
  \  Run Keyword If    '${contract_signed_date}' != ''    Exit For Loop
  \  Sleep  5
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${contract_num}"]
  \  ${contract_signed_date}=  Get Value  name=contract[signed_date]
  ${return_value}  Get Value  name=contract[signed_date]
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-cancel']
  [return]  ${return_value}

Отримати інформацію про contracts[0].period.startDate
  Подивитись на учасників
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Контракт')]
  ${contract_start_date}=  Get Value  name=contract[start_date]
  :FOR    ${INDEX}    IN RANGE    1    30
  \  Run Keyword If    '${contract_start_date}' != ''    Exit For Loop
  \  Sleep  5
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="0"]
  \  ${contract_start_date}=  Get Value  name=contract[start_date]
  ${return_value}    Get Value  name=contract[start_date]

#cat  :FOR    ${INDEX}    IN RANGE    1    15
#cat  \  ${contract_start_date_not_empty}  Run Keyword And Return Status  Should Not Be Empty  xpath=//input[@name='contract[start_date]']
#cat  \  Exit For Loop If  ${contract_start_date_not_empty}
#cat  \  Sleep  5
#cat  \  Reload Page
#cat  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
#cat  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="0"]
#cat  :FOR    ${INDEX}    IN RANGE    1    3
#cat  \  Sleep  5
#cat  \  Reload Page
#cat  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
#cat  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="0"]
#cat  ${return_value}  Get Value  name=contract[start_date]
  Run Keyword If  '${MODE}' in "reporting negotiation openua openeu openua_defense"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
#cat12_01_2019  Run Keyword If  '${MODE}' in "openua_defense"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-cancel']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']
  [return]  ${return_value}

Отримати інформацію про contracts[1].period.startDate
  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Контракт')]
  ${contract_num}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  2
  ...  ELSE  Set Variable  1
  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${contract_num}"]
  ${contract_start_date}=  Get Value  name=contract[start_date]
  :FOR    ${INDEX}    IN RANGE    1    30
  \  Run Keyword If    '${contract_start_date}' != ''    Exit For Loop
  \  Sleep  5
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${contract_num}"]
  \  ${contract_start_date}=  Get Value  name=contract[start_date]
  ${return_value}    Get Value  name=contract[start_date]

#cat  :FOR    ${INDEX}    IN RANGE    1    15
#cat  \  ${contract_start_date_not_empty}  Run Keyword And Return Status  Should Not Be Empty  xpath=//input[@name='contract[start_date]']
#cat  \  Exit For Loop If  ${contract_start_date_not_empty}
#cat  \  Sleep  5
#cat  \  Reload Page
#cat  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
#cat  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${contract_num}"]
#cat  :FOR    ${INDEX}    IN RANGE    1    3
#cat  \  Sleep  5
#cat  \  Reload Page
#cat  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
#cat  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${contract_num}"]
  ${return_value}=  Get Value  xpath=//input[@name='contract[start_date]']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-cancel']
  [return]  ${return_value}

Отримати інформацію про contracts[0].period.endDate
  Подивитись на учасників
  ${contract_button_is_visible}  Run Keyword And Return Status  Page Should Contain Element    xpath=//a[contains(.,'Контракт')]
  ${return_value}  Get Value  name=contract[end_date]
  Run Keyword If  '${MODE}' in "reporting negotiation openua openeu"    Дочекатися І Клікнути  xpath=//button[@id='edit-tender-award-supplier-cancel']
  [return]  ${return_value}

Отримати інформацію про contracts[1].period.endDate
  ${return_value}=  Get Value  xpath=//input[@name='contract[end_date]']
  [return]  ${return_value}

Отримати інформацію про lots[0].title
  ${return_value}  Get Value  name=tender[lots][0][name]
  [return]  ${return_value}

Отримати інформацію про lots[0].value.amount
  ${value}  Get Value  name=tender[lots][0][amount]
  ${return_value}  Convert To Number   ${value}
  [return]  ${return_value}

Отримати інформацію про lots[0].description
  ${return_value}  Get Value  name=tender[lots][0][description]
  [return]  ${return_value}

Отримати інформацію про lots[0].minimalStep.amount
  ${lotStep0}  Get Value  name=tender[lots][0][minimal_step]
  ${return_value}  Convert To Number    ${lotStep0}
  [return]  ${return_value}  

Отримати інформацію про lots[0].value.currency
  ${return_value}=  Get Value  xpath=//*[@name='tender[lots][0][currency]']
  ${return_value}=  Convert To String  UAH
  [return]  ${return_value}
  
Отримати інформацію про lots[0].minimalStep.currency
  ${return_value}=  Get Value  xpath=//*[@name='tender[lots][0][currency]']
  ${return_value}=  Convert To String  UAH
  [return]  ${return_value}  

Отримати інформацію про features[0].title
  ${return_value}  Get Value  xpath=//*[@name='tender[lots][0][features][0][feature_name]']
  [return]  ${return_value}

Отримати інформацію про features[1].title
  ${return_value}  Get Value  xpath=//*[@name='tender[nonprices][0][feature_name]']
  [return]  ${return_value}

Отримати інформацію про features[2].title
  ${return_value}  Get Value  xpath=//*[@name='tender[items][0][features][0][feature_name]']
  [return]  ${return_value}

Отримати інформацію про features[3].title
  ${re_tenderer}=     Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку нецінового показника на тендер'    Get Value  xpath=//*[@name='tender[nonprices][1][feature_name]']
  ${re_lot}=     Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку нецінового показника на лот'    Get Value  xpath=//*[@name='tender[lots][0][features][1][feature_name]']
  ${re_item}=    Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку нецінового показника на предмет'    Get Value  xpath=//*[@name='tender[items][0][features][1][feature_name]']
  ${return_value}=  Run Keyword If    '${TEST NAME}' == 'Відображення заголовку нецінового показника на лот'    Set Variable	   ${re_lot}	
  ...  ELSE IF  '${TEST NAME}' == 'Відображення заголовку нецінового показника на тендер'    Set Variable	   ${re_tenderer}
  ...  ELSE IF  '${TEST NAME}' == 'Відображення заголовку нецінового показника на предмет'    Set Variable   ${re_item}	
  [return]  ${return_value}

Отримати інформацію про features[0].description
  ${return_value}  Get Value  xpath=//*[@name='tender[lots][0][features][0][feature_description]']
  [return]  ${return_value}

Отримати інформацію про features[1].description
  ${return_value}  Get Value  xpath=//*[@name='tender[nonprices][0][feature_description]']
  [return]  ${return_value}   

Отримати інформацію про features[2].description
  ${return_value}  Get Value  xpath=//*[@name='tender[items][0][features][0][feature_description]']
  [return]  ${return_value}   

Отримати інформацію про features[3].description
  ${re_tenderer}=     Run Keyword If    '${TEST_NAME}' == 'Відображення опису нецінового показника на тендер'    Get Value  xpath=//*[@name='tender[nonprices][1][feature_description]']
  ${re_lot}=     Run Keyword If    '${TEST_NAME}' == 'Відображення опису нецінового показника на лот'    Get Value  xpath=//*[@name='tender[lots][0][features][1][feature_description]']
  ${re_item}=    Run Keyword If    '${TEST_NAME}' == 'Відображення опису нецінового показника на предмет'    Get Value  xpath=//*[@name='tender[items][0][features][1][feature_description]']
  ${return_value}=  Run Keyword If    '${TEST NAME}' == 'Відображення опису нецінового показника на лот'    Set Variable	   ${re_lot}	
  ...  ELSE IF  '${TEST NAME}' == 'Відображення опису нецінового показника на тендер'    Set Variable	   ${re_tenderer}
  ...  ELSE IF  '${TEST NAME}' == 'Відображення опису нецінового показника на предмет'    Set Variable   ${re_item}	
   [return]  ${return_value}   

Отримати інформацію про features[0].featureOf
  ${return_value}  Get Value  xpath=//*[@name='tender[lots][0][features][0][featureOf]']
  [return]  ${return_value}  
  
Отримати інформацію про features[1].featureOf
  ${return_value}  Get Value  xpath=//*[@name='tender[nonprices][0][featureOf]']
  [return]  ${return_value}      

Отримати інформацію про features[2].featureOf
  ${return_value}  Get Value  xpath=//*[@name='tender[items][0][features][0][featureOf]']
  [return]  ${return_value}    

Отримати інформацію про features[3].featureOf
  ${re_item}=    Run Keyword If    '${TEST_NAME}' == 'Відображення відношення нецінового показника на предмет'    Get Value  xpath=//*[@name='tender[items][0][features][1][featureOf]']
  ${re_lot}=     Run Keyword If    '${TEST_NAME}' == 'Відображення відношення нецінового показника на лот'    Get Value  xpath=//*[@name='tender[lots][0][features][1][featureOf]']
  ${re_tenderer}=     Run Keyword If    '${TEST_NAME}' == 'Відображення відношення нецінового показника на тендер'    Get Value  xpath=//*[@name='tender[nonprices][1][featureOf]']
  ${return_value}=  Run Keyword If    '${TEST NAME}' == 'Відображення відношення нецінового показника на тендер'    Set Variable	   ${re_tenderer}
  ...  ELSE IF  '${TEST NAME}' == 'Відображення відношення нецінового показника на лот'    Set Variable	   ${re_lot}
  ...  ELSE IF  '${TEST NAME}' == 'Відображення відношення нецінового показника на предмет'    Set Variable   ${re_item}	
  Log Many  CAT888 features[3].featureOf ${return_value}
  [return]  ${return_value}    

Отримати інформацію про enquiryPeriod.clarificationsUntil
  ${return_value}  Get Value  xpath=//input[@name='tender[enquiry_period][clarifications_until]']
  ${return_value}=  parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про qualifications[0].status
  ${return_value}  Get Value  xpath=//input[@id='tender-edit-prequalification-qualification-status-0']
  [return]  ${return_value}

Отримати інформацію про qualifications[1].status
  ${return_value}  Get Value  xpath=//input[@id='tender-edit-prequalification-qualification-status-1']
  [return]  ${return_value}

Отримати інформацію про qualificationPeriod.endDate
  ${return_value}  Get Value  xpath=//*[@name='tender[qualification_period_end]']
  [return]  ${return_value}  

Отримати інформацію про auctionPeriod.startDate
  ${return_value}  Get Value  xpath=//*[@name='tender[auction_period][start_date]']
  [return]  ${return_value} 

Отримати інформацію про auctionPeriod.endDate
  ${return_value}  Get Value  xpath=//*[@name='tender[auction_period][end_date]']
  [return]  ${return_value}
  
Отримати інформацію про lots[0].auctionPeriod.startDate
  ${return_value}  Get Value  xpath=//*[@name='tender[lots][0][auction_period][start_date]']
  [return]  ${return_value} 

Отримати інформацію про lots[0].auctionPeriod.endDate
  ${return_value}  Get Value  xpath=//*[@name='tender[lots][0][auction_period][end_date]']
  [return]  ${return_value}
  
Отримати інформацію про lots[1].title
  ${return_value}  Get Value  name=tender[lots][1][name]
  [return]  ${return_value}

Отримати інформацію про lots[1].value.amount
  ${value}  Get Value  name=tender[lots][1][amount]
  ${return_value}  Convert To Number   ${value}
  [return]  ${return_value}

Отримати інформацію про lots[1].description
  ${return_value}  Get Value  name=tender[lots][1][description]
  [return]  ${return_value}

Отримати інформацію про lots[1].minimalStep.amount
  ${lotStep1}  Get Value  name=tender[lots][1][minimal_step]
  ${return_value}  Convert To Number    ${lotStep1}
  [return]  ${return_value}  

Отримати інформацію про lots[1].value.currency
  ${return_value}=  Get Value  xpath=//*[@name='tender[lots][1][currency]']
  ${return_value}=  Convert To String  UAH
  [return]  ${return_value}
  
Отримати інформацію про lots[1].minimalStep.currency
  ${return_value}=  Get Value  xpath=//*[@name='tender[lots][1][currency]']
  ${return_value}=  Convert To String  UAH
  [return]  ${return_value}

Отримати інформацію про stage2TenderID
  ${return_value}=  Get Element Attribute  xpath=//input[@id='edit-tender-go-stage2-button']@data-stage2-id
  [return]  ${return_value}

Отримати інформацію про value
  ${return_value}=  Get Element Attribute  xpath=//input[@id='edit-tender-go-stage2-button']@data-stage2-id
  [return]  ${return_value}

Отримати інформацію про funders[0].name
  ${value}  Get Value  xpath=//input[@name='tender[funders][0][name]']
#cat  ${return_value}=  Set Variable If  '${value}' == 'World Bank'  World Bank  none
  ${return_value}=  Set Variable If  '${value}' == 'Світовий Банк'  Світовий Банк  none
  [return]  ${return_value}

Отримати інформацію про funders[0].address.locality
  ${return_value}  Get Value  xpath=//input[@name='tender[funders][0][locality]']
  [return]  ${return_value}

Отримати інформацію про funders[0].address.countryName
  ${return_value}=  Get Value  xpath=//input[@name='tender[funders][0][country]']
  [return]  ${return_value}

Отримати інформацію про funders[0].address.postalCode
  ${return_value}=  Get Value  xpath=//input[@name='tender[funders][0][postal_code]']
  [return]  ${return_value}

Отримати інформацію про funders[0].address.region
  ${return_value}=  Get Value  xpath=//input[@name='tender[funders][0][region]']
  [return]  ${return_value}

Отримати інформацію про funders[0].address.streetAddress
  ${return_value}=  Get Value  xpath=//input[@name='tender[funders][0][street]']
  [return]  ${return_value}
  
Отримати інформацію про funders[0].contactPoint.url
  ${return_value}=  Get Value  xpath=//input[@name='tender[funders][0][url]']
  [return]  ${return_value}
  
Отримати інформацію про funders[0].identifier.id
  ${value}  Get Value  xpath=//input[@name='tender[funders][0][name]']
  ${return_value}=  Set Variable If  '${value}' == 'Світовий Банк'  44000  none
  [return]  ${return_value}

Отримати інформацію про funders[0].identifier.legalName
  ${value}  Get Value  xpath=//input[@name='tender[funders][0][legal_name]']
  ${return_value}=  Get Value  xpath=//input[@name='tender[funders][0][legal_name]']
  [return]  ${return_value}
  
Отримати інформацію про funders[0].identifier.scheme
  ${value}  Get Value  xpath=//input[@name='tender[funders][0][name]']
  ${return_value}=  Set Variable If  '${value}' == 'Світовий Банк'  XM-DAC  none
  [return]  ${return_value}

#                                  ESCO                          #
Отримати інформацію про minimalStepPercentage
  ${value}  Get Value  xpath=//input[@name='tender[minimal_step_percentage]']
  ${return_value}=   convert_string_to_float  ${value}
  ${return_value}=  get_value_minimalStepPercentage  ${return_value}
  [return]  ${return_value}

Отримати інформацію про NBUdiscountRate
  ${value}  Get Value  xpath=//input[@name='tender[nbu_rate]']
  ${return_value}=   convert_string_to_float  ${value}
  [return]  ${return_value}

Отримати інформацію про fundingKind
  ${return_value}  Get Value  xpath=//input[@name='tender[funding_value]']
  [return]  ${return_value}

Отримати інформацію про yearlyPaymentsPercentageRange
  ${value}  Get Value  xpath=//input[@name='tender[yearly_payment_percentage_range]']
  ${return_value}=   convert_string_to_float  ${value}
  [return]  ${return_value}

Отримати інформацію про lots[0].minimalStepPercentage
  ${value}  Get Value  xpath=//input[@name='tender[lots][0][minimal_step_percentage]']
  ${return_value}=   convert_string_to_float  ${value}
  ${return_value}=  get_value_minimalStepPercentage  ${return_value}
  [return]  ${return_value}

Отримати інформацію про lots[0].fundingKind
  ${return_value}  Get Value  xpath=//input[@name='tender[lots][0][funding]']
  [return]  ${return_value}

Отримати інформацію про lots[0].yearlyPaymentsPercentageRange
  ${value}  Get Value  xpath=//input[@name='tender[lots][0][yearly_payment_percentage_range]']
  ${return_value}=   convert_string_to_float  ${value}
  [return]  ${return_value}

Отримати інформацію про mainProcurementCategory
  ${return_value}=  Get Value  xpath=//input[@name='tender[main_procurement_category]']
  [return]  ${return_value}

Select award-value-amount
  [Arguments]  ${click_selector}
  :FOR    ${INDEX}    IN RANGE    1    15
  \  ${contract_value_is_visible}  Run Keyword And Return Status  Element Should Be Visible  xpath=//*[@id='edit-tender-award-value-amount']
  \  Exit For Loop If  ${contract_value_is_visible}
  \  Sleep  15
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  \  Дочекатися І Клікнути                       xpath=//${click_selector}

Visible edit-tender-award-item-supplier
  [Arguments]  ${click_selector}
  :FOR    ${INDEX}    IN RANGE    1    15
  \  ${award_is_visible}  Run Keyword And Return Status  Element Should Be Visible  xpath=//${click_selector}
  \  Exit For Loop If  ${award_is_visible}
  \  Sleep  15
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
