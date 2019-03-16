ukr+en@er$777#!/usr/bin/env python
# -*- coding: utf-8 -*-
*** Settings ***

#Library  Selenium2Screenshots
Library  Selenium2Library
Library  String
Library  DateTime
Library  ukrtender_service.py
Library  get_xpath.py
Library  adapt_data.py
Resource  subkeywords.robot
Resource  view.robot

*** Variables ***

${mail}          test_test@test.com
${telephone}     +380630000000
${bid_number}
${auction_url}

*** Variables ***
${sign_in}                                                      id=login-link
${login_sign_in}                                                id=username-34
${password_sign_in}                                             id=user_password-34

*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${adapted_data}=  Run Keyword If  '${username}' == 'ukrtender_Owner'
  ...    ukrtender_service.adapt_data    ${tender_data}
  ...    ELSE    ukrtender_service.adapt_data_view    ${tender_data}
  [return]  ${adapted_data}

Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser   ${USERS.users['${ARGUMENTS[0]}'].homepage}   ${USERS.users['${ARGUMENTS[0]}'].browser}   alias=${ARGUMENTS[0]}
  Set Window Size   @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'ukrtender_Viewer'   Login  ${ARGUMENTS[0]}
  Set Global Variable  ${contract_visible}   contract_not_visible

Login
  [Arguments]  ${username}
  Дочекатися І Клікнути   xpath=//nav[@id="site-navigation"]/descendant::a[@class="menu-login"]
#cat  Sleep   1
  Input text      xpath=//input[@id='username-34']          ${USERS.users['${username}'].login}
  Input text      xpath=//input[@id='user_password-34']       ${USERS.users['${username}'].password}
  Дочекатися І Клікнути    xpath=//input[@id='um-submit-btn']
#cat  Sleep   2


#                                    TENDER OPERATIONS                                           #

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data

  Switch Browser     ${ARGUMENTS[0]}
  Дочекатися І Клікнути  xpath=//nav[@id="site-navigation"]/descendant::a[@class="menu-tenders"]
  Дочекатися І Клікнути  xpath=//a[contains(.,'Нова закупівля')]
  Дочекатися І Клікнути   xpath=//*[@name='tender[procedure_type]']
  Scroll To Element       xpath=//*[@name='tender[procedure_type]']
  Run Keyword If  "${mode}" == "belowThreshold"  Заповнити поля для допорогової закупівлі  ${ARGUMENTS[1]}
  ...  ELSE IF  "${mode}" == "openua"   Заповнити поля для понадпорогів укр  ${ARGUMENTS[1]}
  ...  ELSE IF  "${mode}" == "openeu"   Заповнити поля для понадпорогів укр  ${ARGUMENTS[1]}
  ...  ELSE IF  "${mode}" == "open_competitive_dialogue"   Заповнити поля для КД  ${ARGUMENTS[1]}
  ...  ELSE IF  "${mode}" in "negotiation reporting"   Заповнити поля для переговорної процедури  ${ARGUMENTS[1]}
  ...  ELSE IF  "${mode}" in "openua_defense"   Заповнити поля для ПППО  ${ARGUMENTS[1]}
  ...  ELSE IF  "${mode}" in "below_funders"   Заповнити поля для допорогової закупівлі  ${ARGUMENTS[1]}
  ...  ELSE IF  "${mode}" in "open_esco"   Заповнити поля для esco  ${ARGUMENTS[1]}
  
  Sleep  3
  Execute Javascript  quinta.showLoader()
  Дочекатися І Клікнути                       xpath=//*[text()="Оголосити закупівлю"]
#cat  Sleep  15
  Run Keyword And Ignore Error  Wait Until Element Is Visible  xpath=//button[@id='edit-tender-information-dialog-submit']  5
  Run Keyword And Ignore Error  Click Element   xpath=//button[@id='edit-tender-information-dialog-submit']
  Run Keyword And Ignore Error  Wait Until Element Is Visible  xpath=//button[@id='edit-tender-confirm-dialog-submit']  5
  Run Keyword And Ignore Error  Click Element   xpath=//button[@id='edit-tender-confirm-dialog-submit']
  Run Keyword And Ignore Error  Wait Until Element Is Visible  xpath=//*[text()="Оголосити закупівлю"]  5
  Run Keyword And Ignore Error  Click Element   xpath=//*[text()="Оголосити закупівлю"]
  Run Keyword And Ignore Error  Wait Until Element Is Visible  xpath=//button[@id='edit-tender-information-dialog-submit']  5
  Run Keyword And Ignore Error  Click Element   xpath=//button[@id='edit-tender-information-dialog-submit']
#cat  Sleep  1

#cat  Sleep  5
  ${loader_visible}=  Get Value  xpath=//input[@name="loader_exists"]
#  Run Keyword If  "${loader_visible}" == "1"  Waiting for sync
  Waiting for sync
#cat  Wait Until Element Is Not Visible  xpath=//div[@id="loading"]  100
  Sleep  5
  ${tender_UAid}=  Get Text  xpath=//a[@id="tender-information-external-id"]
  :FOR    ${INDEX}    IN RANGE    1    15
  \  Run Keyword If    '${tender_UAid}' != ''    Exit For Loop
  \  Sleep  10
  \  ${tender_UAid}=  Get Text  xpath=//a[@id="tender-information-external-id"]
  [Return]  ${tender_UAid}

Waiting for sync
  ${loader_visible}=  Get Value  xpath=//input[@name="loader_exists"]
  :FOR    ${INDEX}    IN RANGE    1    25
  \  Run Keyword If    '${loader_visible}' != '1'    Exit For Loop
  \  Sleep  10
  \  ${loader_visible}=  Get Value  xpath=//input[@name="loader_exists"]

Заповнити поля для допорогової закупівлі
#cat переносим в допороговую
  [Arguments]  ${tender_data}
##### Дубляж  
  ${prepared_tender_data}=   Get From Dictionary    ${tender_data}                       data
  ${items}=                  Get From Dictionary    ${prepared_tender_data}               items
  #${features}=               Get From Dictionary    ${prepared_tender_data}               features
  ${proc_name}=              Get From Dictionary    ${prepared_tender_data.procuringEntity}               name
  ${proc_telephone}=              Get From Dictionary    ${prepared_tender_data.procuringEntity.contactPoint}               telephone
  ${title}=                  Get From Dictionary    ${prepared_tender_data}               title
  ${title_en}=               Get From Dictionary    ${prepared_tender_data}               title_en
  ${description}=            Get From Dictionary    ${prepared_tender_data}               description
  ${description_en}=         Get From Dictionary    ${prepared_tender_data}               description_en

  ${budget}=                 Get From Dictionary    ${prepared_tender_data.value}         amount
  ${budget}=                 ukrtender_service.convert_float_to_string                    ${budget}
  ${step_rate}=              Get From Dictionary    ${prepared_tender_data.minimalStep}   amount
  ${step_rate}=              ukrtender_service.convert_float_to_string                    ${step_rate}
  ${enquiry_period}=        Get From Dictionary   ${prepared_tender_data}                enquiryPeriod
  ${enquiry_period_start_date}=        ukrtender_service.convert_date_to_string            ${enquiry_period.startDate}
  ${enquiry_period_end_date}=        ukrtender_service.convert_date_to_string            ${enquiry_period.endDate}
  ${tender_period}=          Get From Dictionary   ${prepared_tender_data}                tenderPeriod
  ${tender_period_start_date}=  ukrtender_service.convert_date_to_string  ${tender_period.startDate}
  ${tender_period_end_date}=  ukrtender_service.convert_date_to_string  ${tender_period.endDate}
  ${countryName}=   Get From Dictionary   ${prepared_tender_data.procuringEntity.address}       countryName
  ${item_description}=    Get From Dictionary    ${items[0]}    description
  ${item_description_en}=    Get From Dictionary    ${items[0]}    description_en
  ${delivery_start_date}=    Get From Dictionary    ${items[0].deliveryDate}   startDate
#cat  ${delivery_start_date}=    ukrtender_service.convert_date_to_string    ${delivery_start_date}
  ${delivery_start_date}=    ukrtender_service.convert_delivery_date_to_string    ${delivery_start_date}
  ${delivery_end_date}=      Get From Dictionary   ${items[0].deliveryDate}   endDate
#cat  ${delivery_end_date}=      ukrtender_service.convert_date_to_string  ${delivery_end_date}
  ${delivery_end_date}=      ukrtender_service.convert_delivery_date_to_string  ${delivery_end_date}
  ${item_delivery_country}=     Get From Dictionary    ${items[0].deliveryAddress}    countryName
  ${item_delivery_region}=      Get From Dictionary    ${items[0].deliveryAddress}    region
  ${item_delivery_region}=     ukrtender_service.get_delivery_region    ${item_delivery_region}
  ${item_locality}=  Get From Dictionary  ${items[0].deliveryAddress}  locality
  ${item_delivery_address_street_address}=  Get From Dictionary  ${items[0].deliveryAddress}  streetAddress
  ${item_delivery_postal_code}=  Get From Dictionary  ${items[0].deliveryAddress}  postalCode
  ${latitude}=  Get From Dictionary  ${items[0].deliveryLocation}  latitude
  ${latitude}=  ukrtender_service.convert_coordinates_to_string    ${latitude}
  ${longitude}=  Get From Dictionary  ${items[0].deliveryLocation}    longitude
  ${longitude}=  ukrtender_service.convert_coordinates_to_string    ${longitude}
  ${dk_21_desc}=  Get From Dictionary   ${items[0].classification}         description
  ${dkpp_id1}=        Convert To String     Не визначено
  ${budget2}=        convert_float_to_string  ${budget}
 
  ${unit_name}=                 Get From Dictionary         ${items[0].unit}                name
  ${unit_code}=                 Get From Dictionary         ${items[0].unit}                code
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${name}=      Get From Dictionary   ${prepared_tender_data.procuringEntity.contactPoint}       name
##### Дубляж  
  Select From List By Value  xpath=//*[@name='tender[procedure_type]']  belowThreshold
  ${acc}=      Run Keyword If  "${SUITE_NAME}" == "Tests Files.Complaints"   Get From Dictionary   ${prepared_tender_data}    procurementMethodDetails
  Run Keyword If  "${SUITE_NAME}" == "Tests Files.Complaints"  Execute Javascript  quinta.initAccelerator('${acc}')
  Run Keyword If  "${SUITE_NAME}" == "Tests Files.Complaints"  Execute Javascript  quinta.skipAuction()

  ${is_funders}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${tender_data.data}  funders
  Run Keyword If  ${is_funders}  Run Keywords
  ...  Click Element  name=tender[has_funder]
  ...  AND  Log Many  ${SUITE_NAME} id=edit-tender-funder-enable
  Дочекатися І Клікнути               name=tender[name]  
  Input text                          name=tender[name]     ${title}
  Input text                          name=tender[description]     ${description}
  Sleep  2

  Clear Element Text    xpath=//*[@name="tender[procuringentity][legalname]"]
  Input text                          xpath=//*[@name="tender[procuringentity][legalname]"]   ${proc_name}
  Дочекатися І Клікнути                       xpath=//*[@name="tender[procuringentity][phone]"]
  Input text                          xpath=//*[@name="tender[procuringentity][phone]"]   ${proc_telephone}
  
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Input text                          name=tender[amount]   ${budget2}
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Click Element  name=tender[rate_amount]
  LOG  list("${step_rate}")
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Input text  name=tender[rate_amount]  ${step_rate}
  Click Element                       xpath=//*[@name='tender[main_procurement_category]']
  Select From List By Value  xpath=//*[@name='tender[main_procurement_category]']  ${prepared_tender_data.mainProcurementCategory}
  Input text                          xpath=//*[@name="tender[specification_period_start]"]  ${enquiry_period_start_date}
  Input text                          xpath=//*[@name="tender[specification_period]"]  ${enquiry_period_end_date}
  Run Keyword And Ignore Error  Input text                          xpath=//*[@name="tender[reception_from]"]  ${tender_period_start_date}
  Input text                          xpath=//*[@name="tender[reception_to]"]  ${tender_period_end_date}
  Wait Until Element Is Visible       xpath=//*[@name='tender[items][0][dk_021_2015][title]']   90

 
  Input text                          name=tender[items][0][dk_021_2015][title]    ${dk_21_desc}
  Дочекатися І Клікнути  xpath=//*[@name='tender[items][0][dk_021_2015][title]']
  Wait Until Element Is Visible  xpath=//*[contains(@class, 'dk_021_2015_hightlight')]
  Дочекатися І Клікнути                       xpath=//*[contains(@class, 'dk_021_2015_hightlight')]
  
  ${dk_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item[0]}  additionalClassifications
  ${is_CPV_other}=  Run Keyword And Return Status  Should Be Equal  '${items[0].classification.id}'  '99999999-9'
  ${is_MOZ}=  Run Keyword And Return Status  Should Be Equal  '${items[0].additionalClassifications[0].scheme}'  'INN'
  Run Keyword If  ${dk_status} or ${is_MOZ}  Вибрати додатковий класифікатор  ${items}  0  ${is_MOZ}

  Log Many  CAT777delivery_start_date ${delivery_start_date}
  Log Many  CAT777delivery_end_date ${delivery_end_date}
  Input text                          name=tender[items][0][item_name]    ${item_description}
  Select From List By Label  xpath=//*[@name='tender[items][0][unit]']  ${unit_name}
  ${item_quantity}=        convert_float_to_string_3f  ${items[0].quantity}
  Run Keyword And Ignore Error  Input text                          name=tender[items][0][item_quantity]   ${item_quantity}
  Input Text                          xpath=//*[@name='tender[items][0][reception_from]']  ${delivery_start_date}
  Input text                          xpath=//*[@name='tender[items][0][reception_to]']  ${delivery_end_date}
  Click Element                       xpath=//*[@name='tender[items][0][region]']
  
  Sleep  2
  Select From List By Label  xpath=//*[@name='tender[items][0][region]']  ${item_delivery_region}
  Sleep  2
  Click Element                       xpath=//*[@name='tender[items][0][country]']
  Select From List By Label  xpath=//*[@name='tender[items][0][country]']  ${item_delivery_country}
  
  Input Text                          xpath=//*[@name='tender[items][0][locality]']    ${item_locality}
  Input text                          name=tender[items][0][post_index]  ${item_delivery_postal_code}
  Input text                          xpath=//*[@name='tender[items][0][address]']  ${item_delivery_address_street_address}
  Input text                          xpath=//*[@name='tender[items][0][latitude]']  ${latitude}
  Input text                          xpath=//*[@name='tender[items][0][longitude]']  ${longitude}

  Log Many  CAT below_funders====${mode} NUMBER_OF_LOTS==${NUMBER_OF_LOTS}
  ${lot_value_amount}=     Run Keyword If  ${NUMBER_OF_LOTS} == 1      convert_float_to_string  ${prepared_tender_data.lots[0].value.amount}
  ${lot_step_rate}=        Run Keyword If  ${NUMBER_OF_LOTS} == 1      convert_float_to_string  ${prepared_tender_data.lots[0].minimalStep.amount}
  Run Keyword If  ${NUMBER_OF_LOTS} == 1   Run Keywords
  ...  Дочекатися І Клікнути  name=tender[multi_lot]
  ...  AND  Input text                          name=tender[lots][0][name]   ${prepared_tender_data.lots[0].title}
  ...  AND  Input text                          name=tender[lots][0][description]   ${prepared_tender_data.lots[0].description}
  ...  AND  Input text                          name=tender[lots][0][amount]   ${lot_value_amount}
  ...  AND  Input text                          name=tender[lots][0][minimal_step]   ${lot_step_rate}
  ...  AND  Select From List By Label  xpath=//select[@name='tender[items][0][lot]']   Лот 1
  Sleep  2
  Run Keyword if   '${mode}' == 'multi'   Додати предмет   items

Заповнити поля для понадпорогів укр
#cat переносим в допороговую
  [Arguments]  ${tender_data}
  ${prepared_tender_data}=   Get From Dictionary    ${tender_data}                       data
  ${items}=                  Get From Dictionary    ${prepared_tender_data}               items
  ${lots}                    Get From Dictionary   ${prepared_tender_data}                   lots

  ${lot_value_amount2}=        convert_float_to_string  ${tender_data.data.lots[0].value.amount}
  ${lot_step_rate2}=        convert_float_to_string  ${tender_data.data.lots[0].minimalStep.amount}

  Select From List By Value  xpath=//*[@name='tender[procedure_type]']  ${tender_data.data.procurementMethodType}
  Click Element  name=tender[multi_lot]

  Input text                          name=tender[lots][0][name]   ${tender_data.data.lots[0].title}
  Input text                          name=tender[lots][0][description]   ${tender_data.data.lots[0].description}
  Input text                          name=tender[lots][0][amount]   ${lot_value_amount2}
  Input text                          name=tender[lots][0][minimal_step]   ${lot_step_rate2}

  Дочекатися І Клікнути               name=tender[name]  
  Input text                          name=tender[name]     ${tender_data.data.title}
  Input text                          name=tender[description]     ${tender_data.data.description}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//*[@name="tender[procuringentity][legalname]"]
  Clear Element Text    xpath=//*[@name="tender[procuringentity][legalname]"]
  Input text                          xpath=//*[@name="tender[procuringentity][legalname]"]   ${tender_data.data.procuringEntity.name}
  Дочекатися І Клікнути                       xpath=//*[@name="tender[procuringentity][phone]"]
  Input text                          xpath=//*[@name="tender[procuringentity][phone]"]   ${tender_data.data.procuringEntity.contactPoint.telephone}

  ${budget}=                 ukrtender_service.convert_float_to_string                    ${tender_data.data.value.amount}
  ${step_rate}=              ukrtender_service.convert_float_to_string                    ${tender_data.data.minimalStep.amount}
  ${budget2}=        convert_float_to_string  ${budget}
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Input text                          name=tender[amount]   ${budget2}
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Click Element  name=tender[rate_amount]
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Input text  name=tender[rate_amount]  ${step_rate}

  Click Element                       xpath=//*[@name='tender[main_procurement_category]']
  Select From List By Value  xpath=//*[@name='tender[main_procurement_category]']  ${tender_data.data.mainProcurementCategory}

  ${tender_period_start_date}=  ukrtender_service.convert_date_to_string  ${tender_data.data.tenderPeriod.startDate}
  ${tender_period_end_date}=  ukrtender_service.convert_date_to_string  ${tender_data.data.tenderPeriod.endDate}
  Run Keyword And Ignore Error  Input text                          xpath=//*[@name="tender[reception_from]"]  ${tender_period_start_date}
  Input text                          xpath=//*[@name="tender[reception_to]"]  ${tender_period_end_date}

  Run Keyword If  ${tender_meat}  ukrtender.Додати нецінові критерії2  ${tender_data}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  Додати предмет при створенні  ${items}

  Run Keyword If  '${mode}' == 'openeu'   Run Keywords
  ...  Input Text  xpath=//*[@name="tender[procuringentity][name_en]"]   ${tender_data.data.procuringEntity.name_en}
  ...  AND  Input Text  xpath=//*[@name="tender[name_en]"]   ${tender_data.data.title_en}
  ...  AND  Input Text  xpath=//*[@name="tender[description_en]"]   ${tender_data.data.description_en}
  ...  AND  Input Text  xpath=//*[@name="tender[lots][0][name_en]"]      ${tender_data.data.lots[0].title_en}
#cat  ...  AND  Input Text  xpath=//*[@name="tender[items][0][item_name_en]"]  ${item_description_en}
  
Заповнити поля для переговорної процедури
#cat переносим в допороговую + reporting
  [Arguments]  ${tender_data}
  Log  ${tender_data}
##### Дубляж  
  ${prepared_tender_data}=   Get From Dictionary    ${tender_data}                       data
  ${items}=                  Get From Dictionary    ${prepared_tender_data}               items

  ${title}=                  Get From Dictionary    ${prepared_tender_data}               title
  ${title_en}=               Get From Dictionary    ${prepared_tender_data}               title_en
  ${description}=            Get From Dictionary    ${prepared_tender_data}               description
  ${description_en}=         Get From Dictionary    ${prepared_tender_data}               description_en

  ${budget}=                 Get From Dictionary    ${prepared_tender_data.value}         amount
  ${budget}=                 ukrtender_service.convert_float_to_string                    ${budget}
  ${countryName}=   Get From Dictionary   ${prepared_tender_data.procuringEntity.address}       countryName
  ${item_description}=    Get From Dictionary    ${items[0]}    description
  ${item_description_en}=    Get From Dictionary    ${items[0]}    description_en
  ${delivery_start_date}=    Get From Dictionary    ${items[0].deliveryDate}   startDate
  ${delivery_start_date}=    ukrtender_service.convert_date_to_string    ${delivery_start_date}
  ${delivery_end_date}=      Get From Dictionary   ${items[0].deliveryDate}   endDate
  ${delivery_end_date}=      ukrtender_service.convert_date_to_string  ${delivery_end_date}
  ${item_delivery_country}=     Get From Dictionary    ${items[0].deliveryAddress}    countryName
  ${item_delivery_region}=      Get From Dictionary    ${items[0].deliveryAddress}    region
  ${item_delivery_region}=     ukrtender_service.get_delivery_region    ${item_delivery_region}
  ${item_locality}=  Get From Dictionary  ${items[0].deliveryAddress}  locality
  ${item_delivery_address_street_address}=  Get From Dictionary  ${items[0].deliveryAddress}  streetAddress
  ${item_delivery_postal_code}=  Get From Dictionary  ${items[0].deliveryAddress}  postalCode
  ${latitude}=  Get From Dictionary  ${items[0].deliveryLocation}  latitude
  ${latitude}=  ukrtender_service.convert_coordinates_to_string    ${latitude}
  ${longitude}=  Get From Dictionary  ${items[0].deliveryLocation}    longitude
  ${longitude}=  ukrtender_service.convert_coordinates_to_string    ${longitude}
  ${dk_21_desc}=  Get From Dictionary   ${items[0].classification}         description
  ${dkpp_id1}=        Convert To String     Не визначено
  ${budget2}=        convert_float_to_string  ${budget}
 
  ${unit_name}=                 Get From Dictionary         ${items[0].unit}                name
  ${unit_code}=                 Get From Dictionary         ${items[0].unit}                code
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity

# item 2
  ${item_description_en2}=    Get From Dictionary    ${items[1]}    description_en
  ${delivery_start_date2}=    Get From Dictionary    ${items[1].deliveryDate}   startDate
  ${delivery_start_date2}=    ukrtender_service.convert_date_to_string    ${delivery_start_date2}
  ${delivery_end_date21}=      Get From Dictionary   ${items[1].deliveryDate}   endDate
  ${delivery_end_date2}=      ukrtender_service.convert_date_to_string  ${delivery_end_date21}
  ${item_delivery_country2}=     Get From Dictionary    ${items[1].deliveryAddress}    countryName
  ${item_delivery_region2}=      Get From Dictionary    ${items[1].deliveryAddress}    region
  ${item_delivery_region2}=     ukrtender_service.get_delivery_region    ${item_delivery_region2}
  ${item_locality2}=  Get From Dictionary  ${items[1].deliveryAddress}  locality
  ${item_delivery_address_street_address2}=  Get From Dictionary  ${items[1].deliveryAddress}  streetAddress
  ${item_delivery_postal_code2}=  Get From Dictionary  ${items[1].deliveryAddress}  postalCode
  ${latitude2}=  Get From Dictionary  ${items[1].deliveryLocation}  latitude
  ${latitude2}=  ukrtender_service.convert_coordinates_to_string    ${latitude2}
  ${longitude2}=  Get From Dictionary  ${items[1].deliveryLocation}    longitude
  ${longitude2}=  ukrtender_service.convert_coordinates_to_string    ${longitude2}
  ${cpv_id2}=           Get From Dictionary   ${items[1].classification}         id
  ${dk_21_desc2}=  Get From Dictionary   ${items[1].classification}         description
  #${dkpp_desc}=     Get From Dictionary   ${items[1].additionalClassifications[0]}   description
  #${dkpp_id}=       Get From Dictionary   ${items[1].additionalClassifications[0]}  id
  ${unit_name2}=                 Get From Dictionary         ${items[1].unit}                name
  ${unit_code2}=                 Get From Dictionary         ${items[1].unit}                code
  ${quantity2}=      Get From Dictionary   ${items[1]}                        quantity

  ${procurement_type}=      Get From Dictionary   ${prepared_tender_data}   procurementMethodType
##### Дубляж  
  
  Select From List By Value  xpath=//*[@name='tender[procedure_type]']  ${procurement_type}

  Run Keyword If  "${mode}" == "negotiation"   Input Text  name=tender[negotiation][prove]  ${tender_data.data.causeDescription}
  Run Keyword If  "${mode}" == "negotiation"   Select From List By Value  xpath=//*[@name="tender[negotiation][type]"]  ${tender_data.data.cause}
  Clear Element Text    xpath=//*[@name="tender[procuringentity][name]"]
  Input Text  name=tender[procuringentity][name]  ${tender_data.data.procuringEntity.contactPoint.name}
  Input Text  name=tender[procuringentity][identifier_id]  ${tender_data.data.procuringEntity.identifier.id}
  Clear Element Text    xpath=//*[@name="tender[procuringentity][phone]"]
  Input Text  name=tender[procuringentity][phone]  ${tender_data.data.procuringEntity.contactPoint.telephone}
  Clear Element Text    xpath=//*[@name="tender[procuringentity][email]"]
  Input Text  name=tender[procuringentity][email]  ${tender_data.data.procuringEntity.contactPoint.email}
  Clear Element Text    xpath=//*[@name="tender[procuringentity][url]"]
  Input Text  name=tender[procuringentity][url]  ${tender_data.data.procuringEntity.contactPoint.url}
  Select From List By Value  xpath=//*[@name="tender[procuringentity][country]"]  ${tender_data.data.procuringEntity.address.countryName}
  Select From List By Value  xpath=//*[@name="tender[procuringentity][region]"]  ${tender_data.data.procuringEntity.address.region}
  Clear Element Text    xpath=//*[@name="tender[procuringentity][postalcode]"]
  Input Text  name=tender[procuringentity][postalcode]  ${tender_data.data.procuringEntity.address.postalCode}
  Clear Element Text    xpath=//*[@name="tender[procuringentity][locality]"]
  Input Text  name=tender[procuringentity][locality]  ${tender_data.data.procuringEntity.address.locality}
  Clear Element Text    xpath=//*[@name="tender[procuringentity][address]"]
  Input Text  name=tender[procuringentity][address]  ${tender_data.data.procuringEntity.address.streetAddress}


  Дочекатися І Клікнути               name=tender[name]  
  Input text  name=tender[name]     ${tender_data.data.title}
  Run Keyword And Ignore Error  Input Text  name=tender[name_en]  ${tender_data.data.title_en}
  Run Keyword And Ignore Error  Input Text  name=tender[name_ru]  ${tender_data.data.title_ru}
  Input text  name=tender[description]     ${tender_data.data.description}
  Run Keyword And Ignore Error  Input Text  name=tender[description_en]  ${tender_data.data.description_en}
  Run Keyword And Ignore Error  Input Text  name=tender[description_ru]  ${tender_data.data.description_ru}
  Sleep  2
  Clear Element Text    xpath=//*[@name="tender[procuringentity][legalname]"]
  Input text                          xpath=//*[@name="tender[procuringentity][legalname]"]   ${prepared_tender_data.procuringEntity.name}

  Input text                          name=tender[amount]   ${budget2}
  Click Element                       xpath=//*[@name='tender[main_procurement_category]']
  Select From List By Value  xpath=//*[@name='tender[main_procurement_category]']  ${prepared_tender_data.mainProcurementCategory}
  
  Wait Until Element Is Visible       xpath=//*[@name='tender[items][0][dk_021_2015][title]']   90
  Input text                          name=tender[items][0][dk_021_2015][title]    ${dk_21_desc}
  Sleep  4
  ${class}=  conc_class  ${items[0].classification.description}  ${items[0].classification.id}
  Log Many  CAT888 ${class}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//div[contains(text(),'${class}')]
  ${present_class}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${class}')]
  Run Keyword If    ${present_class}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${class}')]

  ${dk_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item[0]}  additionalClassifications
  ${is_CPV_other}=  Run Keyword And Return Status  Should Be Equal  '${items[0].classification.id}'  '99999999-9'
  ${is_MOZ}=  Run Keyword And Return Status  Should Be Equal  '${items[0].additionalClassifications[0].scheme}'  'INN'
  Run Keyword If  ${dk_status} or ${is_MOZ}  Вибрати додатковий класифікатор  ${items}  0  ${is_MOZ}

  Sleep  2
  Input text                          name=tender[items][0][item_name]    ${item_description}
  Sleep  2
  Select From List By Label  xpath=//*[@name='tender[items][0][unit]']  ${unit_name}
  ${item_quantity}=        convert_float_to_string_3f  ${items[0].quantity}
  Run Keyword And Ignore Error  Input text                          name=tender[items][0][item_quantity]   ${item_quantity}
  Input Text                          xpath=//*[@name='tender[items][0][reception_from]']  ${delivery_start_date}
  Input text                          xpath=//*[@name='tender[items][0][reception_to]']  ${delivery_end_date}
  Click Element                       xpath=//*[@name='tender[items][0][region]']
  
  Sleep  2
  Select From List By Label  xpath=//*[@name='tender[items][0][region]']  ${item_delivery_region}
  Sleep  2
  Click Element                       xpath=//*[@name='tender[items][0][country]']
  Select From List By Label  xpath=//*[@name='tender[items][0][country]']  ${item_delivery_country}
  
  Input Text                          xpath=//*[@name='tender[items][0][locality]']    ${item_locality}
  Input text                          name=tender[items][0][post_index]  ${item_delivery_postal_code}
  Input text                          xpath=//*[@name='tender[items][0][address]']  ${item_delivery_address_street_address}
  Input text                          xpath=//*[@name='tender[items][0][latitude]']  ${latitude}
  Input text                          xpath=//*[@name='tender[items][0][longitude]']  ${longitude}

#Дабавить item 2
  Click Element                       xpath=//a[contains(.,'Додати позицію')]
  Дочекатися І Клікнути               name=tender[items][1][item_name]
  Input text                          name=tender[items][1][item_name]    ${items[1].description} 
  Select From List By Label  xpath=//*[@name='tender[items][1][unit]']  ${unit_name2}
  ${item_quantity2}=        convert_float_to_string_3f  ${items[1].quantity}
  Run Keyword And Ignore Error  Input text                          name=tender[items][1][item_quantity]   ${item_quantity2}
  Wait Until Element Is Visible       xpath=//*[@name='tender[items][1][dk_021_2015][title]']   90
  Input text                          name=tender[items][1][dk_021_2015][title]    ${dk_21_desc2}

  ${class1}=  conc_class  ${items[1].classification.description}  ${items[1].classification.id}
  Log Many  CAT888 ${class1}
  Sleep  4

# old class
  ${present_item}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//*[contains(@class, 'dk_021_2015_hightlight-1')]
  Run Keyword If    ${present_item}    Дочекатися І Клікнути                       xpath=//*[contains(@class, 'dk_021_2015_hightlight-1')]
  Sleep  2
  ${present_item1}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//*[contains(@class, 'dk_021_2015_hightlight-1')]
  Run Keyword If    ${present_item1}    Click Element                       xpath=//*[contains(@class, 'dk_021_2015_hightlight-1')]
  ${dk_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item[1]}  additionalClassifications
  ${is_CPV_other}=  Run Keyword And Return Status  Should Be Equal  '${items[1].classification.id}'  '99999999-9'
  ${is_MOZ}=  Run Keyword And Return Status  Should Be Equal  '${items[1].additionalClassifications[0].scheme}'  'INN'
  Run Keyword If  ${dk_status} or ${is_MOZ}  Вибрати додатковий класифікатор  ${items}  1  ${is_MOZ}

  Input Text                          xpath=//*[@name='tender[items][1][reception_from]']  ${delivery_start_date2}
  Input text                          xpath=//*[@name='tender[items][1][reception_to]']  ${delivery_end_date2}
  Click Element                       xpath=//*[@name='tender[items][1][region]']
  
  Sleep  2
  Select From List By Label  xpath=//*[@name='tender[items][1][region]']  ${item_delivery_region2}
  Sleep  2
  Click Element                       xpath=//*[@name='tender[items][1][country]']
  Select From List By Label  xpath=//*[@name='tender[items][1][country]']  ${item_delivery_country2}
  
  Input Text                          xpath=//*[@name='tender[items][1][locality]']    ${item_locality2}
  Input text                          name=tender[items][1][post_index]  ${item_delivery_postal_code2}
  Input text                          xpath=//*[@name='tender[items][1][address]']  ${item_delivery_address_street_address2}
  Input text                          xpath=//*[@name='tender[items][1][latitude]']  ${latitude2}
  Input text                          xpath=//*[@name='tender[items][1][longitude]']  ${longitude2}

  
  Sleep  2
  Run Keyword if   '${mode}' == 'multi'   Додати предмет   items


Заповнити поля для КД
  [Arguments]  ${tender_data}

  ${lot_value_amount2}=        convert_float_to_string  ${tender_data.data.lots[0].value.amount}
  ${lot_step_rate2}=        convert_float_to_string  ${tender_data.data.lots[0].minimalStep.amount}

  Select From List By Value  xpath=//*[@name='tender[procedure_type]']  ${tender_data.data.procurementMethodType}
  Click Element  name=tender[multi_lot]

  Input text                          name=tender[lots][0][name]   ${tender_data.data.lots[0].title}
  Input text                          name=tender[lots][0][description]   ${tender_data.data.lots[0].description}
  Input text                          name=tender[lots][0][amount]   ${lot_value_amount2}
  Input text                          name=tender[lots][0][minimal_step]   ${lot_step_rate2}

  Дочекатися І Клікнути               name=tender[name]  
  Input text                          name=tender[name]     ${tender_data.data.title}
  Input text                          name=tender[description]     ${tender_data.data.description}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//*[@name="tender[procuringentity][legalname]"]
  Clear Element Text    xpath=//*[@name="tender[procuringentity][legalname]"]
  Input text                          xpath=//*[@name="tender[procuringentity][legalname]"]   ${tender_data.data.procuringEntity.name}
  Дочекатися І Клікнути                       xpath=//*[@name="tender[procuringentity][phone]"]
  Input text                          xpath=//*[@name="tender[procuringentity][phone]"]   ${tender_data.data.procuringEntity.contactPoint.telephone}

  ${budget}=                 ukrtender_service.convert_float_to_string                    ${tender_data.data.value.amount}
  ${step_rate}=              ukrtender_service.convert_float_to_string                    ${tender_data.data.minimalStep.amount}
  ${budget2}=        convert_float_to_string  ${budget}
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Input text                          name=tender[amount]   ${budget2}
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Click Element  name=tender[rate_amount]
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Input text  name=tender[rate_amount]  ${step_rate}

  Click Element                       xpath=//*[@name='tender[main_procurement_category]']
  Select From List By Value  xpath=//*[@name='tender[main_procurement_category]']  ${tender_data.data.mainProcurementCategory}

  ${tender_period_start_date}=  ukrtender_service.convert_date_to_string  ${tender_data.data.tenderPeriod.startDate}
  ${tender_period_end_date}=  ukrtender_service.convert_date_to_string  ${tender_data.data.tenderPeriod.endDate}
  Run Keyword And Ignore Error  Input text                          xpath=//*[@name="tender[reception_from]"]  ${tender_period_start_date}
  Input text                          xpath=//*[@name="tender[reception_to]"]  ${tender_period_end_date}

  Run Keyword If  ${tender_meat}  ukrtender.Додати нецінові критерії2  ${tender_data}
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  Додати предмет при створенні  ${items}

  Run Keyword If  '${tender_data.data.procurementMethodType}'=='competitiveDialogueEU'   Run Keywords
  ...  Input Text  xpath=//*[@name="tender[procuringentity][name_en]"]   ${tender_data.data.procuringEntity.name_en}
  ...  AND  Input Text  xpath=//*[@name="tender[name_en]"]   ${tender_data.data.title_en}
  ...  AND  Input Text  xpath=//*[@name="tender[description_en]"]   ${tender_data.data.description_en}
  ...  AND  Input Text  xpath=//*[@name="tender[lots][0][name_en]"]      ${tender_data.data.lots[0].title_en}
#cat  ...  AND  Input Text  xpath=//*[@name="tender[items][0][item_name_en]"]  ${item_description_en}
  

Заповнити поля для ПППО
  [Arguments]  ${tender_data}
  ${prepared_tender_data}=   Get From Dictionary    ${tender_data}                       data
  ${items}=                  Get From Dictionary    ${prepared_tender_data}               items
  ${lots}                    Get From Dictionary   ${prepared_tender_data}                   lots
  ${features}=               Get From Dictionary    ${prepared_tender_data}               features

  ${lot_value_amount2}=        convert_float_to_string  ${tender_data.data.lots[0].value.amount}
  ${lot_step_rate2}=        convert_float_to_string  ${tender_data.data.lots[0].minimalStep.amount}

  Select From List By Value  xpath=//*[@name='tender[procedure_type]']  ${tender_data.data.procurementMethodType}
  Execute Javascript    quinta.loadTender( '{ "lots": [{"id":"${lots[0].id}"}], "items": [{"id":"${items[0].id}"}], "features": [{"code": "${features[0].code}","featureOf": "${features[0].featureOf}", "relatedItem": "${features[0].relatedItem}"}, {"code": "${features[1].code}", "featureOf": "${features[1].featureOf}"}, {"code": "${features[2].code}", "featureOf": "${features[2].featureOf}", "relatedItem": "${features[2].relatedItem}"}] }')
  Click Element  name=tender[multi_lot]
  Input text                          name=tender[lots][0][name]   ${tender_data.data.lots[0].title}
  Input text                          name=tender[lots][0][description]   ${tender_data.data.lots[0].description}
  Input text                          name=tender[lots][0][amount]   ${lot_value_amount2}
  Input text                          name=tender[lots][0][minimal_step]   ${lot_step_rate2}

  Дочекатися І Клікнути               name=tender[name]  
  Input text                          name=tender[name]     ${tender_data.data.title}
  Input text                          name=tender[description]     ${tender_data.data.description}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//*[@name="tender[procuringentity][legalname]"]
  Clear Element Text    xpath=//*[@name="tender[procuringentity][legalname]"]
  Input text                          xpath=//*[@name="tender[procuringentity][legalname]"]   ${tender_data.data.procuringEntity.name}
  Дочекатися І Клікнути                       xpath=//*[@name="tender[procuringentity][phone]"]
  Input text                          xpath=//*[@name="tender[procuringentity][phone]"]   ${tender_data.data.procuringEntity.contactPoint.telephone}

  ${budget}=                 ukrtender_service.convert_float_to_string                    ${tender_data.data.value.amount}
  ${step_rate}=              ukrtender_service.convert_float_to_string                    ${tender_data.data.minimalStep.amount}
  ${budget2}=        convert_float_to_string  ${budget}
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Input text                          name=tender[amount]   ${budget2}
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Click Element  name=tender[rate_amount]
  Run Keyword If  ${NUMBER_OF_LOTS} == 0      Input text  name=tender[rate_amount]  ${step_rate}

  Click Element                       xpath=//*[@name='tender[main_procurement_category]']
  Select From List By Value  xpath=//*[@name='tender[main_procurement_category]']  ${tender_data.data.mainProcurementCategory}

  ${tender_period_start_date}=  ukrtender_service.convert_date_to_string  ${tender_data.data.tenderPeriod.startDate}
  ${tender_period_end_date}=  ukrtender_service.convert_date_to_string  ${tender_data.data.tenderPeriod.endDate}
  Run Keyword And Ignore Error  Input text                          xpath=//*[@name="tender[reception_from]"]  ${tender_period_start_date}
  Input text                          xpath=//*[@name="tender[reception_to]"]  ${tender_period_end_date}
  
  Run Keyword If  ${tender_meat}  ukrtender.Додати нецінові критерії2  ${tender_data}
#cat  ${items}=         Get From Dictionary   ${tender_data.data}               items
  Додати предмет при створенні  ${items}

  Run Keyword If  '${mode}' == 'openua_defense'   Run Keywords
  ...  Input Text  xpath=//*[@name="tender[name_en]"]   ${tender_data.data.title_en}
  ...  AND  Input Text  xpath=//*[@name="tender[description_en]"]   ${tender_data.data.description_en}
  ...  AND  Input Text  xpath=//*[@name="tender[lots][0][name_en]"]      ${tender_data.data.lots[0].title_en}
#cat  ...  AND  Input Text  xpath=//*[@name="tender[items][0][item_name_en]"]  ${item_description_en}
  

Заповнити поля для esco
  [Arguments]  ${tender_data}

  Select From List By Value  xpath=//*[@name='tender[procedure_type]']  ${tender_data.data.procurementMethodType}
  Click Element  name=tender[multi_lot]
  Input text                          name=tender[lots][0][name]   ${tender_data.data.lots[0].title}
  Input text                          name=tender[lots][0][description]   ${tender_data.data.lots[0].description}
  ${minimalStepPercentage1}=        set_value_minimalStepPercentage  ${tender_data.data.lots[0].minimalStepPercentage}
  ${yearlyPaymentsPercentageRange1}=        set_value_minimalStepPercentage  ${tender_data.data.lots[0].yearlyPaymentsPercentageRange}
  ${minimalStepPercentage1}=        ukrtender_service.convert_esco__float_to_string  ${minimalStepPercentage1}
  ${yearlyPaymentsPercentageRange1}=        ukrtender_service.convert_esco__float_to_string  ${yearlyPaymentsPercentageRange1}
  Select From List By Value  xpath=//select[@name='tender[lots][0][funding]']  ${tender_data.data.lots[0].fundingKind}
  Input text                          xpath=//input[@name='tender[lots][0][minimal_step_percentage]']  ${minimalStepPercentage1}
  Input text                          xpath=//input[@name='tender[lots][0][yearly_payment_percentage_range]']  ${yearlyPaymentsPercentageRange1}

  Click Element                       xpath=//*[@name='tender[main_procurement_category]']
  Select From List By Value  xpath=//*[@name='tender[main_procurement_category]']  ${tender_data.data.mainProcurementCategory}
  
  Дочекатися І Клікнути               name=tender[name]  
  Input text                          name=tender[name]     ${tender_data.data.title}
  Input text                          name=tender[description]     ${tender_data.data.description}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//*[@name="tender[procuringentity][legalname]"]
  Clear Element Text    xpath=//*[@name="tender[procuringentity][legalname]"]
  Input text                          xpath=//*[@name="tender[procuringentity][legalname]"]   ${tender_data.data.procuringEntity.name}
  Дочекатися І Клікнути                       xpath=//*[@name="tender[procuringentity][phone]"]
  Input text                          xpath=//*[@name="tender[procuringentity][phone]"]   ${tender_data.data.procuringEntity.contactPoint.telephone}

  Select From List By Value  xpath=//select[@name='tender[funding]']  ${tender_data.data.fundingKind}
  ${nbu_rate_percent}=        set_value_minimalStepPercentage  ${tender_data.data.NBUdiscountRate}
  ${nbu_rate_percent}=        convert_esco__float_to_string  ${nbu_rate_percent}
  ${minimal_step_percentage}=        set_value_minimalStepPercentage  ${tender_data.data.minimalStepPercentage}
  ${minimal_step_percentage}=        convert_esco__float_to_string  ${minimal_step_percentage}
  Input text                          xpath=//input[@name='tender[nbu_rate_percent]']  ${nbu_rate_percent}
  Input text                          xpath=//input[@name='tender[minimal_step_percentage]']  ${minimal_step_percentage}

  ${tender_period_start_date}=  ukrtender_service.convert_date_to_string  ${tender_data.data.tenderPeriod.startDate}
  ${tender_period_end_date}=  ukrtender_service.convert_date_to_string  ${tender_data.data.tenderPeriod.endDate}
  Run Keyword And Ignore Error  Input text                          xpath=//*[@name="tender[reception_from]"]  ${tender_period_start_date}
  Input text                          xpath=//*[@name="tender[reception_to]"]  ${tender_period_end_date}
  
  Run Keyword If  ${tender_meat}  ukrtender.Додати нецінові критерії2  ${tender_data}
  
  ${items}=         Get From Dictionary   ${tender_data.data}               items
  Додати предмет при створенні  ${items}
  Run Keyword If  '${tender_data.data.procurementMethodType}'=='esco'   Run Keywords
  ...  Input Text  xpath=//*[@name="tender[procuringentity][name_en]"]   ${tender_data.data.procuringEntity.name_en}
  ...  AND  Input Text  xpath=//*[@name="tender[name_en]"]   ${tender_data.data.title_en}
  ...  AND  Input Text  xpath=//*[@name="tender[description_en]"]   ${tender_data.data.description_en}
  ...  AND  Input Text  xpath=//*[@name="tender[lots][0][name_en]"]      ${tender_data.data.lots[0].title_en}
#cat  ...  AND  Input Text  xpath=//*[@name="tender[items][0][item_name_en]"]  ${items[0].description_en}


Додати предмет при створенні
  [Arguments]  ${items}
  ${delivery_start_date}=    Run Keyword If  "${mode}" not in "open_esco"  Get From Dictionary    ${items[0].deliveryDate}   startDate
  ${delivery_start_date}=    Run Keyword If  "${mode}" not in "open_esco"  ukrtender_service.convert_date_to_string    ${delivery_start_date}
  ${delivery_end_date}=      Run Keyword If  "${mode}" not in "open_esco"  Get From Dictionary   ${items[0].deliveryDate}   endDate
  ${delivery_end_date}=      Run Keyword If  "${mode}" not in "open_esco"  ukrtender_service.convert_date_to_string  ${delivery_end_date}
  ${item_quantity}=        convert_float_to_string_3f  ${items[0].quantity}

  Wait Until Element Is Visible       xpath=//*[@name='tender[items][0][dk_021_2015][title]']   90
  Input text                          name=tender[items][0][dk_021_2015][title]    ${items[0].classification.description}
  Дочекатися І Клікнути  xpath=//*[@name='tender[items][0][dk_021_2015][title]']
  Wait Until Element Is Visible  xpath=//*[contains(@class, 'dk_021_2015_hightlight')]
  Дочекатися І Клікнути                       xpath=//*[contains(@class, 'dk_021_2015_hightlight')]

  ${dk_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item[0]}  additionalClassifications
  ${is_CPV_other}=  Run Keyword And Return Status  Should Be Equal  '${items[0].classification.id}'  '99999999-9'
  ${is_MOZ}=  Run Keyword And Return Status  Should Be Equal  '${items[0].additionalClassifications[0].scheme}'  'INN'
  Run Keyword If  ${dk_status} or ${is_MOZ}  Вибрати додатковий класифікатор  ${items}  0  ${is_MOZ}

  Input text                          name=tender[items][0][item_name]    ${items[0].description}
  Select From List By Label  xpath=//*[@name='tender[items][0][unit]']  ${items[0].unit.name}

  ${latitude}=  ukrtender_service.convert_coordinates_to_string    ${items[0].deliveryLocation.latitude}
  ${longitude}=  ukrtender_service.convert_coordinates_to_string    ${items[0].deliveryLocation.longitude}
  ${item_delivery_region}=     ukrtender_service.get_delivery_region    ${items[0].deliveryAddress.region}
  Run Keyword And Ignore Error  Input text                          name=tender[items][0][item_quantity]   ${item_quantity}

  Run Keyword And Ignore Error  Input Text                          xpath=//*[@name='tender[items][0][reception_from]']  ${delivery_start_date}
  Run Keyword And Ignore Error  Input text                          xpath=//*[@name='tender[items][0][reception_to]']  ${delivery_end_date}
  Click Element                       xpath=//*[@name='tender[items][0][region]']
  
  Select From List By Label  xpath=//*[@name='tender[items][0][region]']  ${item_delivery_region}
  Click Element                       xpath=//*[@name='tender[items][0][country]']
  Select From List By Label  xpath=//*[@name='tender[items][0][country]']  ${items[0].deliveryAddress.countryName}
  
  Input Text                          xpath=//*[@name='tender[items][0][locality]']    ${items[0].deliveryAddress.locality}
  Input text                          name=tender[items][0][post_index]  ${items[0].deliveryAddress.postalCode}
  Input text                          xpath=//*[@name='tender[items][0][address]']  ${items[0].deliveryAddress.streetAddress}
  Input text                          xpath=//*[@name='tender[items][0][latitude]']  ${latitude}
  Input text                          xpath=//*[@name='tender[items][0][longitude]']  ${longitude}

  Select From List By Label  xpath=//select[@name='tender[items][0][lot]']   Лот 1

  Run Keyword If  "${mode}" in "open_esco openua_defense openeu open_competitive_dialogue"   Run Keyword And Ignore Error  Input Text  xpath=//*[@name="tender[items][0][item_name_en]"]  ${items[0].description_en}

  
Вибрати додатковий класифікатор
  [Arguments]  ${items}  ${index}  ${is_MOZ}
  Log Many  CAT888 ${items[${index}].additionalClassifications[0].scheme}
  Log Many  CAT888-index ${index}

  Run Keyword If  '${items[${index}].additionalClassifications[0].scheme}' == 'ДК018'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 018-2000')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_018_2000][title]']   ${items[${index}].additionalClassifications[0].description}
  ...  AND  ${present2}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present2}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If  '${items[${index}].additionalClassifications[0].scheme}' == 'ДК003'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 003-2010')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_003_2010][title]']   ${items[${index}].additionalClassifications[0].description}
  ...  AND  ${present3}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present3}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If  '${items[${index}].additionalClassifications[0].scheme}' == 'spec'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'Спеціальні норми та інше')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_special][title]']   ${items[${index}].additionalClassifications[0].description}
  ...  AND  ${present4}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present4}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
#cat#cat  INN
  Run Keyword If  '${items[${index}].additionalClassifications[0].scheme}' == 'INN'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'МОЗ МНН')]
  ...  AND  Clear Element Text    xpath=//input[@name='add_classificator[dk_moz_mnn][title]']
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_moz_mnn][title]']   ${items[${index}].additionalClassifications[0].description}
  Sleep  4
  Log Many  CAT888 ${items[${index}].additionalClassifications[0].description}
  ${present_inn}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${items[${index}].additionalClassifications[0].description}')]
  Run Keyword If    ${present_inn}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${items[${index}].additionalClassifications[0].description}') and contains(@class,'ui-menu-item-wrapper')]
#cat#cat  ATX
  Log Many  CAT888 ${items[${index}].additionalClassifications[1].description}
  ${con_class}=  Run Keyword If  '${items[${index}].additionalClassifications[1].scheme}' == 'ATC'   conc_class  ${items[${index}].additionalClassifications[1].description}  ${items[${index}].additionalClassifications[1].id}
  Log Many  CAT888 ${con_class}
  Run Keyword If  '${items[${index}].additionalClassifications[1].scheme}' == 'ATC'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'МОЗ АТХ')]
  ...  AND  Clear Element Text    xpath=//input[@name='add_classificator[dk_moz_atx][title]']
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_moz_atx][title]']   ${items[${index}].additionalClassifications[1].description}
  Sleep  4
  ${present_atx}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${con_class}')]
  Run Keyword If    ${present_atx}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${con_class}') and contains(@class,'ui-menu-item-wrapper')]

  Sleep  2
  Дочекатися І Клікнути  xpath=//button[contains(.,'Додати класифікатори')]

Вибрати додатковий класифікатор2
  [Arguments]  ${item}  ${index}  ${is_MOZ}
  Log Many  CAT888 ${item.additionalClassifications[0].scheme}

  Run Keyword If  '${item.additionalClassifications[0].scheme}' == 'ДК018'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 018-2000')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_018_2000][title]']   ${items.additionalClassifications[0].description}
  ...  AND  ${present2}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present2}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If  '${item.additionalClassifications[0].scheme}' == 'ДК003'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 003-2010')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_003_2010][title]']   ${item.additionalClassifications[0].description}
  ...  AND  ${present3}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present3}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If  '${item.additionalClassifications[0].scheme}' == 'spec'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'Спеціальні норми та інше')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_special][title]']   ${item.additionalClassifications[0].description}
  ...  AND  ${present4}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present4}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
#cat#cat  INN
  Run Keyword If  '${item.additionalClassifications[0].scheme}' == 'INN'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'МОЗ МНН')]
  ...  AND  Clear Element Text    xpath=//input[@name='add_classificator[dk_moz_mnn][title]']
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_moz_mnn][title]']   ${item.additionalClassifications[0].description}
  Sleep  4
  Log Many  CAT888 ${item.additionalClassifications[0].description}
  ${present_inn}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${item.additionalClassifications[0].description}')]
  Run Keyword If    ${present_inn}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${item.additionalClassifications[0].description}')]
#cat#cat  ATX
  Log Many  CAT888 ${item.additionalClassifications[1].description}
  ${con_class}=  Run Keyword If  '${item.additionalClassifications[1].scheme}' == 'ATC'   conc_class  ${item.additionalClassifications[1].description}  ${item.additionalClassifications[1].id}
  Log Many  CAT888 ${con_class}
  Run Keyword If  '${item.additionalClassifications[1].scheme}' == 'ATC'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'МОЗ АТХ')]
  ...  AND  Clear Element Text    xpath=//input[@name='add_classificator[dk_moz_atx][title]']
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_moz_atx][title]']   ${item.additionalClassifications[1].description}
  Sleep  4
  ${present_atx}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${con_class}')]
  Run Keyword If    ${present_atx}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${con_class}')]

  Sleep  2
  Дочекатися І Клікнути  xpath=//button[contains(.,'Додати класифікатори')]

  
Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}  ${save_key}=${Empty}
  [Documentation]
  Switch browser   ${username}
#  ${current_location}=   Get Location
  Go to   ${USERS.users['${username}'].homepage}
  Set Global Variable  ${glo_tender_UAid}   ${tender_uaid}
  Click Element  xpath=//nav[@id="site-navigation"]/descendant::a[@class="menu-tenders"]
  Click Element            xpath=//input[@id='purchase_list_search1']
  Input Text                       xpath=//input[@id='purchase_list_search1']    ${tender_uaid}

  Wait Until Keyword Succeeds  6x  20s  Run Keywords
  ...  Click Element  xpath=//input[@id='purchase-button-search-1']
  ...  AND  Wait Until Element Is Visible  xpath=//a[contains(@data-tenderid, '${tender_uaid}')]  10
  Click Element    xpath=//a[contains(@data-tenderid, '${tender_uaid}')]

  
Оновити сторінку з тендером
  [Arguments]  ${username}  ${tender_uaid}
  Switch Browser    ${username}
#cat  ukrtender.Пошук тендера по ідентифікатору    ${username}   ${tender_uaid}
  Reload Page


Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}
#cat  Switch Browser   ${username}
  Run Keyword If  '${fieldname}' == 'status' or '${fieldname}' == 'enquiryPeriod.endDate'  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
  Run Keyword If  '${fieldname}' == 'stage2TenderID'  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If  "${TEST_NAME}" == 'Неможливість подати цінову пропозицію без нецінових показників'  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If  '${fieldname}' == 'stage2TenderID'  ukrtender.Пошук тендера по ідентифікатору    ${username}   ${tender_uaid}
  Run Keyword And Return  view.Отримати інформацію про ${fieldname}


Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  Switch Browser    ${username}
  Run Keyword If    '${TEST_NAME}' == 'Неможливість редагувати однопредметний тендер менше ніж за 2 дні до завершення періоду подання пропозицій'    Fail  "Неможливість редагувати однопредметний тендер менше ніж за 2 дні до завершення періоду подання пропозицій"
  ...  ELSE   Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ...  ELSE  ukrtender.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If  '${fieldname}' == 'tenderPeriod.endDate'  subkeywords.Змінити дату  ${fieldvalue}
  Run Keyword If  '${fieldname}' == 'description'  subkeywords.Змінити опис  ${fieldvalue}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//*[text()="Редагувати закупівлю"]
  Sleep  2
  Run Keyword And Ignore Error  Редагувати закупівлю
  Run Keyword If    '${TEST_NAME}' == 'Можливість відповісти на запитання до тендера після продовження періоду прийому пропозицій'    Execute Javascript  quinta.refreshTenderFromProzorro()
#cat  Sleep  2
#cat  Run Keyword If    '${TEST_NAME}' == 'Можливість відповісти на запитання до тендера після продовження періоду прийому пропозицій'    Reload Page


Завантажити документ
  [Arguments]   ${username}  ${file}  ${tender_uaid}
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Неможливість додати документацію до тендера під час кваліфікації'    Wait Until Keyword Succeeds    400 s    20 s    subkeywords.Wait For PreQualificationPeriod
  Дочекатися І Клікнути                       xpath=//a[contains(@class,'button edit-tender-add-document')]
  Wait Until Element Is Visible  xpath=//*[@name='tender[document_type]']  5
  Select From List By Value  xpath=//*[@name='tender[document_type]']  biddingDocuments
  Choose File       xpath=//*[@id='edit-tender-document']    ${file}
  Wait Until Element Is Visible  xpath=//a[contains(@class,'areaukrzak-delete-link purchase_button')]  15

  Дочекатися І Клікнути                       xpath=//button[@name='document[save]']
  Дочекатися І Клікнути                       xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword And Ignore Error  Редагувати закупівлю

Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_UAid}
  ${id}=           Get Text           id=mForm:nBid
  ${Ids}   Create List    ${tender_UAid}   ${id}


Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
  Switch browser   ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${contract_num}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  2
  ...  ELSE  Set Variable  1
  Run Keyword If    '${contract_visible}' == 'contract_visible'    Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Run Keyword If    '${contract_visible}' == 'contract_visible'    Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${contract_num}"]
  Wait Until Keyword Succeeds  5 x  10 s  Run Keywords
  ...  Reload Page
  ...  AND  Run Keyword If    '${contract_visible}' == 'contract_visible'    Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  ...  AND  Run Keyword If    '${contract_visible}' == 'contract_visible'    Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${contract_num}"]
  ...  AND  Wait Until Element Is Visible  xpath=//a[contains(.,'${doc_id}')]
  ${field_xpath}=  get_xpath.get_document_xpath  ${field}  ${doc_id}
  ${value}=  Run Keyword If   "${field}" == "title"  Get Text    ${field_xpath}
  ...  ELSE IF  "${field}" == "documentOf"  Get Element Attribute    ${field_xpath}
  [return]  ${value}


Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  Switch Browser    ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${contract_num}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  2
  ...  ELSE  Set Variable  1
  Run Keyword If    '${contract_visible}' == 'contract_visible'    Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Run Keyword If    '${contract_visible}' == 'contract_visible'    Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${contract_num}"]
#cat  ${url_doc}=    Get Element Attribute    xpath=//a[contains(text(), '${doc_id}')]@href
  ${url_doc}=    Get Element Attribute    xpath=//a[contains(text(), '${doc_id}')]@data-url
  ${file_name}=    Get Text    xpath=//a[contains(text(), '${doc_id}')]
  ${file_name}=    Convert To String    ${file_name}
  ukrtender_service.download_file    ${url_doc}    ${file_name}    ${OUTPUT_DIR}
  [return]  ${file_name}


#                                    ITEM OPERATIONS                                       #


Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  Switch browser    ${username}
  Wait Until Keyword Succeeds  5 x  10 s  Run Keywords
  ...  Reload Page
  ...  AND  Wait Until Page Contains Element  xpath=//input[contains(@value,"${item_id}")]
  Sleep  5
  ${value}=    subkeywords.Отримати дані з поля item    ${field_name}  ${item_id}
  ${value}=    subkeywords.Адаптувати дані з поля item    ${field_name}  ${value}
  [return]    ${value}


Видалити предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${lot_id}=${Empty}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  :FOR    ${INDEX}    IN RANGE    1    45
  \  ${found}  Run Keyword And Return Status  Element Should Be Visible  xpath=//input[contains(@value,"${item_id}")]
  \  Exit For Loop If  ${found}
  \  Sleep  5
  ${Count}=    Get matching xpath count    xpath=//*[text()='Видалити лот']
  ${index_item}=  Get Element Attribute  xpath=//input[contains(@value,"${item_id}")]@name
  ${item_index}=  split_str  ${index_item}
  Дочекатися І Клікнути  xpath=//a[@id='edit-tender-item-remove-button-${item_index}']
  Sleep  3
  Дочекатися І Клікнути    xpath=//a[contains(.,'Редагувати закупівлю')]
  Run Keyword And Ignore Error  Редагувати закупівлю
  Sleep  2
  Execute Javascript  quinta.refreshTenderFromProzorro()



#                                    LOT OPERATIONS                                         #

Створити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Створити лот із предметом закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${lot}  ${item}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${index_lot}=    Get matching xpath count    xpath=//*[text()='Видалити лот']
  ${index_item}=    Get matching xpath count    xpath=//*[text()='Видалити позицію']
  ${lot}=  Set Variable If  '${tender_uaid}' != '${None}'  ${lot.data}  ${lot}
  Log Many  CAT888item ${item}
  Log Many  CAT888item ${lot}
  Log Many  CAT888NUMBER_OF_LOTS ${NUMBER_OF_LOTS}
  Log Many  CAT888 ${NUMBER_OF_ITEMS}
  Дочекатися І Клікнути    xpath=//a[contains(.,'Додати лот')]
  Дочекатися І Клікнути    name=tender[lots][${index_lot}][name]
  Input text                          name=tender[lots][${index_lot}][name]   ${lot.title}
  Input text                          name=tender[lots][${index_lot}][description]   ${lot.description}
  ${lot_value_amount2}=        convert_float_to_string  ${lot.value.amount}
  Input text                          name=tender[lots][${index_lot}][amount]   ${lot_value_amount2}
  ${lot_step_rate}=            convert_float_to_string   ${lot.minimalStep.amount}
  Input text                          name=tender[lots][${index_lot}][minimal_step]   ${lot_step_rate}
  Run Keyword If  '${mode}' == "openua_defense" or '${mode}' == "openeu" or '${mode}' == "open_competitive_dialogue"   Input Text  xpath=//*[@name="tender[lots][${index_lot}][name_en]"]      ${lot.title_en}

#Дабавить item 2
# item 2
  ${delivery_start_date2}=    ukrtender_service.convert_date_to_string    ${item.deliveryDate.startDate}
  ${delivery_end_date2}=      ukrtender_service.convert_date_to_string  ${item.deliveryDate.endDate}
  ${item_delivery_region2}=     ukrtender_service.get_delivery_region    ${item.deliveryAddress.region}
  Дочекатися І Клікнути    xpath=//a[contains(.,'Додати позицію')]
  Дочекатися І Клікнути               name=tender[items][${index_item}][item_name]
  Input text                          name=tender[items][${index_item}][item_name]    ${item.description}
  Select From List By Label  xpath=//*[@name='tender[items][${index_item}][unit]']  ${item.unit.name}
  ${item_quantity}=        convert_float_to_string_3f  ${item.quantity}
  Run Keyword And Ignore Error  Input text                          name=tender[items][${index_item}][item_quantity]   ${item_quantity}
  Wait Until Element Is Visible       xpath=//*[@name='tender[items][${index_item}][dk_021_2015][title]']   90
  Input text                          name=tender[items][${index_item}][dk_021_2015][title]    ${item.classification.description}
  ${class1}=  conc_class  ${item.classification.description}  ${item.classification.id}
  Log Many  CAT888 ${class1}
  Sleep  4
  Дочекатися І Клікнути                       xpath=//div[contains(.,'${class1}')]
  ${dk_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item[1]}  additionalClassifications
  ${is_CPV_other}=  Run Keyword And Return Status  Should Be Equal  '${item.classification.id}'  '99999999-9'
  ${is_MOZ}=  Run Keyword And Return Status  Should Be Equal  '${item.additionalClassifications[0].scheme}'  'INN'
  Run Keyword If  ${dk_status} or ${is_MOZ}  Вибрати додатковий класифікатор2  ${item}  1  ${is_MOZ}
  Run Keyword And Ignore Error  Input Text                          xpath=//*[@name='tender[items][${index_item}][reception_from]']  ${delivery_start_date2}
  Run Keyword And Ignore Error  Input text                          xpath=//*[@name='tender[items][${index_item}][reception_to]']  ${delivery_end_date2}
  Click Element                       xpath=//*[@name='tender[items][${index_item}][region]']
  Sleep  2
  Select From List By Label  xpath=//*[@name='tender[items][${index_item}][region]']  ${item_delivery_region2}
  Sleep  2
  Click Element                       xpath=//*[@name='tender[items][${index_item}][country]']
  Select From List By Label  xpath=//*[@name='tender[items][${index_item}][country]']  ${item.deliveryAddress.countryName}
  Input Text                          xpath=//*[@name='tender[items][${index_item}][locality]']    ${item.deliveryAddress.locality}
  Input text                          name=tender[items][${index_item}][post_index]  ${item.deliveryAddress.postalCode}
  Input text                          xpath=//*[@name='tender[items][${index_item}][address]']  ${item.deliveryAddress.streetAddress}
  ${latitude}=  ukrtender_service.convert_coordinates_to_string    ${item.deliveryLocation.latitude}
  ${longitude}=  ukrtender_service.convert_coordinates_to_string    ${item.deliveryLocation.longitude}
  Input text                          xpath=//*[@name='tender[items][${index_item}][latitude]']  ${latitude}
  Input text                          xpath=//*[@name='tender[items][${index_item}][longitude]']  ${longitude}
  ${class}=  conc_class3  ${lot.title}  ${lot_value_amount2}  ${lot.value.currency}
  ${lot_item}=  Get Text  xpath=//option[contains(@data-lot-title,"${class}")]
  Select From List By Label  xpath=//select[@name='tender[items][${index_item}][lot]']  ${lot_item}
  Run Keyword If  '${mode}' == "openua_defense" or '${mode}' == "openeu" or '${mode}' == "open_competitive_dialogue"   Input Text  xpath=//*[@name="tender[items][${index_item}][item_name_en]"]  ${item.description_en}
  Sleep  3
  Дочекатися І Клікнути    xpath=//a[contains(.,'Редагувати закупівлю')]
  Run Keyword And Ignore Error  Редагувати закупівлю
  Sleep  10
#cat  ${is_visible}=  Run Keyword And Return Status  Element Should Be Visible  xpath=//*[text()="Редагувати закупівлю"]
#cat  Run Keyword If  ${is_visible}  Дочекатися І Клікнути  xpath=//*[text()="Редагувати закупівлю"]
#cat  Run Keyword If  ${is_visible}    Run Keyword And Ignore Error  Редагувати закупівлю


Отримати інформацію із лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${field_name}
  Switch browser    ${username}
  Wait Until Keyword Succeeds  5 x  10 s  Run Keywords
  ...  Reload Page
  ...  AND  Wait Until Page Contains Element  xpath=//input[contains(@value,"${lot_id}")]
  ${value}=    subkeywords.Отримати дані з поля lot    ${field_name}  ${lot_id}
  ${value}=    subkeywords.Адаптувати дані з поля lot    ${field_name}  ${value}
  [return]    ${value}


Змінити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${fieldname}  ${fieldvalue}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Sleep  2
  ${value}=    Run Keyword If  '${fieldname}'!='description'             ukrtender_service.convert_float_to_string                    ${fieldvalue}
  Run Keyword If    '${fieldname}' == 'description'  Input Text  name=tender[lots][0][description]  ${fieldvalue}
  Run Keyword If    '${fieldname}' == 'value.amount'  Input Text  name=tender[lots][0][amount]  ${value}
  Run Keyword If    '${fieldname}' == 'minimalStep.amount'  Input Text  name=tender[lots][0][minimal_step]  ${value}
  Sleep  2
  Scroll To Element    xpath=//*[text()="Редагувати закупівлю"]
  Дочекатися І Клікнути                       xpath=//a[contains(.,'Редагувати закупівлю')]
  Run Keyword And Ignore Error  Редагувати закупівлю
  Sleep  2


Додати предмет закупівлі в лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${item}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${Count}=    Get matching xpath count    xpath=//*[text()='Видалити лот']
  ${Count1}=    Get matching xpath count    xpath=//*[text()='Видалити позицію']
  Log Many  CAT888-Count ${Count}
  Log Many  CAT888-Count1 ${Count1}
  Log Many  CAT888item ${lot_id}
#Дабавить item 3
# item 3
  ${index_item}=  Set Variable  ${Count1}
  ${delivery_start_date2}=    ukrtender_service.convert_date_to_string    ${item.deliveryDate.startDate}
  ${delivery_end_date2}=      ukrtender_service.convert_date_to_string  ${item.deliveryDate.endDate}
  ${item_delivery_region2}=     ukrtender_service.get_delivery_region    ${item.deliveryAddress.region}
  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-item-add-button-1']
  Дочекатися І Клікнути               name=tender[items][${index_item}][item_name]
  Input text                          name=tender[items][${index_item}][item_name]    ${item.description}
  Select From List By Label  xpath=//*[@name='tender[items][${index_item}][unit]']  ${item.unit.name}
  ${item_quantity}=        convert_float_to_string_3f  ${item.quantity}
  Run Keyword And Ignore Error  Input text                          name=tender[items][${index_item}][item_quantity]   ${item_quantity}
#cat  Input text                          name=tender[items][${index_item}][item_quantity]   ${item.quantity}
  Wait Until Element Is Visible       xpath=//*[@name='tender[items][${index_item}][dk_021_2015][title]']   90
  Input text                          name=tender[items][${index_item}][dk_021_2015][title]    ${item.classification.description}
  ${class1}=  conc_class  ${item.classification.description}  ${item.classification.id}
  Log Many  CAT888 ${class1}
  Sleep  4
  Дочекатися І Клікнути                       xpath=//div[contains(.,'${class1}')]
  ${dk_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item[1]}  additionalClassifications
  ${is_CPV_other}=  Run Keyword And Return Status  Should Be Equal  '${item.classification.id}'  '99999999-9'
  ${is_MOZ}=  Run Keyword And Return Status  Should Be Equal  '${item.additionalClassifications[0].scheme}'  'INN'
  Run Keyword If  ${dk_status} or ${is_MOZ}  Вибрати додатковий класифікатор2  ${item}  1  ${is_MOZ}
  Input Text                          xpath=//*[@name='tender[items][${index_item}][reception_from]']  ${delivery_start_date2}
  Input text                          xpath=//*[@name='tender[items][${index_item}][reception_to]']  ${delivery_end_date2}
  Click Element                       xpath=//*[@name='tender[items][${index_item}][region]']
  Sleep  2
  Select From List By Label  xpath=//*[@name='tender[items][${index_item}][region]']  ${item_delivery_region2}
  Sleep  2
  Click Element                       xpath=//*[@name='tender[items][${index_item}][country]']
  Select From List By Label  xpath=//*[@name='tender[items][${index_item}][country]']  ${item.deliveryAddress.countryName}
  Input Text                          xpath=//*[@name='tender[items][${index_item}][locality]']    ${item.deliveryAddress.locality}
  Input text                          name=tender[items][${index_item}][post_index]  ${item.deliveryAddress.postalCode}
  Input text                          xpath=//*[@name='tender[items][${index_item}][address]']  ${item.deliveryAddress.streetAddress}
  ${latitude}=  ukrtender_service.convert_coordinates_to_string    ${item.deliveryLocation.latitude}
  ${longitude}=  ukrtender_service.convert_coordinates_to_string    ${item.deliveryLocation.longitude}
  Input text                          xpath=//*[@name='tender[items][${index_item}][latitude]']  ${latitude}
  Input text                          xpath=//*[@name='tender[items][${index_item}][longitude]']  ${longitude}

  ${index_lot}=  Get Element Attribute  xpath=//input[contains(@value,"${lot_id}")]@name
  ${lot_index}=  split_str  ${index_lot}
  ${lot_title}=  Get Text  xpath=//select/option[contains(@data-lot-title, "${lot_id}")]
  Select From List By Label  xpath=//select[@name='tender[items][${index_item}][lot]']  ${lot_title}
  Run Keyword If  '${mode}' == "openua_defense" or '${mode}' == "openeu" or '${mode}' == "open_competitive_dialogue"   Input Text  xpath=//*[@name="tender[items][${index_item}][item_name_en]"]  ${item.description_en}
  Sleep  3
  Дочекатися І Клікнути    xpath=//a[contains(.,'Редагувати закупівлю')]
  Run Keyword And Ignore Error  Редагувати закупівлю
  Sleep  10
  ${is_visible}=  Run Keyword And Return Status  Element Should Be Visible  xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword If  ${is_visible}  Дочекатися І Клікнути  xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword If  ${is_visible}    Run Keyword And Ignore Error  Редагувати закупівлю
  
  
Завантажити документ в лот
  [Arguments]    ${username}    ${filepath}    ${TENDER_UAID}    ${lot_id}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
#cat#cat  Select From List By Value  xpath=//*[@name='tender[lots][0][document_type]']  biddingDocuments
#cat#cat  Sleep  2
#cat#cat#cat#cat  Choose File       xpath=//*[@name="lot_multifiles[]"]    ${filepath}
#cat#cat  Sleep  10
  Дочекатися І Клікнути                       xpath=//a[@id='edit-tender-lot-add-document-0']
  Wait Until Element Is Visible  xpath=//*[@name='lot_document[document_type]']  5
  Select From List By Value  xpath=//*[@name='lot_document[document_type]']  biddingDocuments
#cat#cat#cat#cat  Дочекатися І Клікнути                       xpath=//label[@for='edit-tender-lot-document']
  Choose File       xpath=//*[@id='edit-tender-lot-document']    ${filepath}
  Wait Until Element Is Visible  xpath=//a[contains(@class,'areaukrzak-delete-link purchase_button')]  15

  Дочекатися І Клікнути                       xpath=//button[@id='edit-tender-lot-document-save']

  Дочекатися І Клікнути    xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword And Ignore Error  Редагувати закупівлю
  Sleep  3

	
Видалити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  :FOR    ${INDEX}    IN RANGE    1    45
  \  ${found}  Run Keyword And Return Status  Element Should Be Visible  xpath=//input[contains(@value,'${lot_id}')]
  \  Exit For Loop If  ${found}
  \  Sleep  5
  ${index_lot}=  Get Element Attribute  xpath=//input[contains(@value,'${lot_id}')]@name
  ${lot_index}=  split_str  ${index_lot}
  ${item_index}=  Get Element Attribute  xpath=//select/option[contains(@data-lot-title, '${lot_id}') and @selected="selected"]@name
  Дочекатися І Клікнути  xpath=//a[@id='edit-tender-item-remove-button-1']
  Sleep  3
#cat  Дочекатися І Клікнути    xpath=//a[contains(.,'Редагувати закупівлю')]
#cat  Run Keyword And Ignore Error  Редагувати закупівлю
#cat  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//a[@id='edit-tender-lot-remove-button-${lot_index}']
  Sleep  3
  Дочекатися І Клікнути    xpath=//a[contains(.,'Редагувати закупівлю')]
  Run Keyword And Ignore Error  Редагувати закупівлю

Отримати документ до лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}
  ${file_name}=    ukrtender.Отримати документ    ${username}  ${tender_uaid}  ${doc_id}
  [return]  ${file_name}


#                                    FEATURES OPERATIONS                                    #

Додати неціновий показник на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${feature}
  Log Many  CAT888 на тендер
  Log Many  CAT888 на тендер tender_uaid = ${tender_uaid}
  ${Count}=    Get matching xpath count    xpath=//*[text()='Видалити лот']
  ${Count1}=    Get matching xpath count    xpath=//*[text()='Видалити позицію']
  ${Count_tenderer}=  Get matching xpath count  xpath=//input[contains(@value,"tenderer")]
  ${Count_feature}=  Get matching xpath count  xpath=//td[text()="Назва нецінового критерія"]
  Log Many  CAT888 на тендер features  ${feature}
  ${f.title}=   Run Keyword if   ${Count_tenderer} != 0   Set Variable  ${feature.title}
  ...  ELSE  Set Variable   ${feature.title}
  ${f.description}=   Run Keyword if   ${Count_tenderer} != 0   Set Variable  ${feature.description}
  ...  ELSE  Set Variable   ${feature.description}
  ${f_enum}  Set Variable If  ${Count_tenderer} != 0   feature  feature
  Scroll To Element  id=edit-tender-multinonprices
  Execute Javascript    $("#edit-tender-multinonprices").trigger("click")
  ${i}  Set Variable  ${0}
  Input Text  xpath=//*[@name='tender[nonprices][${Count_tenderer}][feature_name]']  ${f.title}
  Wait Until Element Is Visible  xpath=//*[@name='tender[nonprices][${Count_tenderer}][feature_description]']
  Input Text  xpath=//*[@name='tender[nonprices][${Count_tenderer}][feature_description]']  ${f.description}

  :FOR    ${index}  ${element}    IN ENUMERATE  @{${f_enum}.enum}
  \  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
  \  Click Element  xpath=//a[@id='edit-tender-multinonprice-item-${Count_tenderer}-option']
  \  Wait Until Element Is Visible  xpath=//*[@name='tender[nonprices][${Count_tenderer}][enum][${index}][option]']
  \  Input Text     xpath=//*[@name='tender[nonprices][${Count_tenderer}][enum][${index}][option]']  ${element.title}
  \  ${value}  ukrtender_service.convert_float_to_string  ${element.value}
  \  Input Text     xpath=//*[@name='tender[nonprices][${Count_tenderer}][enum][${index}][value]']    ${value}
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на тендер'  Click Element  xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на тендер'    Run Keyword And Ignore Error  Редагувати закупівлю


Додати неціновий показник на тендер при створенні
  [Arguments]  ${username}  ${tender_uaid}  ${features}
  Click Element  xpath=//*[@id='edit-tender-multinonprices']
  ${i}  Set Variable  ${0}
  Input Text  xpath=//*[@name='tender[nonprices][0][feature_name]']  ${features[1].title}
  Input Text  xpath=//*[@name='tender[nonprices][0][feature_description]']  ${features[1].description}

  :FOR    ${index}  ${element}    IN ENUMERATE  @{features[1].enum}
  \  Wait Until Keyword Succeeds  2 x  1 s  Run Keywords
  \  Click Element  xpath=//a[@id='edit-tender-multinonprice-item-0-option']
  \  Wait Until Element Is Visible  xpath=//*[@name='tender[nonprices][0][enum][${index}][option]']
  \  Input Text     xpath=//*[@name='tender[nonprices][0][enum][${index}][option]']  ${element.title}
  \  ${value}  ukrtender_service.convert_float_to_string  ${element.value}
  \  Input Text     xpath=//*[@name='tender[nonprices][0][enum][${index}][value]']    ${value}

Додати неціновий показник на предмет при створенні
  [Arguments]  ${username}  ${tender_uaid}  ${features}  ${item_id}
  ${f_var}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  ${features[0]}  ${features[2]}
  ${num}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  1  0
  Дочекатися і Клікнути  xpath=//*[@id='edit-tender-item-0-feature-add']
  ${i}  Set Variable  ${0}
  Input Text  xpath=//*[@name='tender[items][0][features][${num}][feature_name]']  ${f_var.title}
  Input Text  xpath=//*[@name='tender[items][0][features][${num}][feature_description]']  ${f_var.description}

  :FOR    ${index}  ${element}    IN ENUMERATE  @{f_var.enum}
  \  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
  \  Click Element  xpath=//a[@id='edit-tender-item-0-feature-0-option-add']
  \  Wait Until Element Is Visible  xpath=//*[@name='tender[items][0][features][${num}][enum][${index}][option]']
  \  Input Text     xpath=//*[@name='tender[items][0][features][${num}][enum][${index}][option]']  ${element.title}
  \  Log Many  num=${num} CAT888 на предмет index=${index}
  \  ${value}  ukrtender_service.convert_float_to_string  ${element.value}
  \  Input Text     xpath=//*[@name='tender[items][0][features][${num}][enum][${index}][value]']    ${value}
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'    Click Element                       xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'      Run Keyword And Ignore Error  Редагувати закупівлю

Додати неціновий показник на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${item_id}
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  ukrtender.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${f_var}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  ${feature}  ${feature}
  ${num}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'  1  0
  ${Count_item}=  Get matching xpath count  xpath=//input[contains(@value,"item")]
  Scroll To Element  xpath=//*[@id='edit-tender-item-0-feature-add']
  Дочекатися і Клікнути  xpath=//*[@id='edit-tender-item-0-feature-add']
  ${i}  Set Variable  ${0}
  Input Text  xpath=//*[@name='tender[items][0][features][${num}][feature_name]']  ${f_var.title}
  Input Text  xpath=//*[@name='tender[items][0][features][${num}][feature_description]']  ${f_var.description}

  :FOR    ${index}  ${element}    IN ENUMERATE  @{f_var.enum}
  \  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
  \  Click Element  xpath=//a[@id='edit-tender-item-0-feature-${num}-option-add']
  \  Wait Until Element Is Visible  xpath=//*[@name='tender[items][0][features][${num}][enum][${index}][option]']
  \  Input Text     xpath=//*[@name='tender[items][0][features][${num}][enum][${index}][option]']  ${element.title}
  \  Log Many  num=${num} CAT888 на предмет index=${index}
  \  ${value}  ukrtender_service.convert_float_to_string  ${element.value}
  \  Input Text     xpath=//*[@name='tender[items][0][features][${num}][enum][${index}][value]']    ${value}
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'    Дочекатися і Клікнути                       xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший предмет'      Run Keyword And Ignore Error  Редагувати закупівлю

Додати неціновий показник на лот при створенні
  [Arguments]  ${username}  ${tender_uaid}  ${features}  ${item_id}
  ${f_var}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  ${features[0]}  ${features[0]}
  ${num}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  1  0
  Log Many  CAT888 на лот
  ${numbers_feature}=  Get Length  ${features}
  Scroll To Element  xpath=//*[@id='edit-tender-lot-0-feature-add']
  Дочекатися і Клікнути  xpath=//*[@id='edit-tender-lot-0-feature-add']
  ${i}  Set Variable  ${0}
  Input Text  xpath=//*[@name='tender[lots][0][features][${num}][feature_name]']  ${f_var.title}
  Input Text  xpath=//*[@name='tender[lots][0][features][${num}][feature_description]']  ${f_var.description}

  :FOR    ${index}  ${element}    IN ENUMERATE  @{f_var.enum}
  \  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
  \  Click Element  xpath=//a[@id='edit-tender-lot-0-feature-${num}-option-add']
  \  Wait Until Element Is Visible  xpath=//input[@name='tender[lots][0][features][${num}][enum][${index}][option]']
  \  Input Text     xpath=//*[@name='tender[lots][0][features][${num}][enum][${index}][option]']  ${element.title}
  \  ${value}  ukrtender_service.convert_float_to_string  ${element.value}
  \  Input Text     xpath=//*[@name='tender[lots][0][features][${num}][enum][${index}][value]']    ${value}
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  Click Element  xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'    Run Keyword And Ignore Error  Редагувати закупівлю

Додати неціновий показник на лот
  [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${item_id}
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  ukrtender.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${f_var}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  ${feature}  ${feature}
  ${num}  Set Variable If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  1  0
  Scroll To Element  xpath=//*[@id='edit-tender-lot-0-feature-add']
  Дочекатися і Клікнути  xpath=//*[@id='edit-tender-lot-0-feature-add']
  ${i}  Set Variable  ${0}
  Input Text  xpath=//*[@name='tender[lots][0][features][${num}][feature_name]']  ${f_var.title}
  Input Text  xpath=//*[@name='tender[lots][0][features][${num}][feature_description]']  ${f_var.description}

  :FOR    ${index}  ${element}    IN ENUMERATE  @{f_var.enum}
  \  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
  \  Click Element  xpath=//a[@id='edit-tender-lot-0-feature-${num}-option-add']
  \  Wait Until Element Is Visible  xpath=//input[@name='tender[lots][0][features][${num}][enum][${index}][option]']
  \  Input Text     xpath=//*[@name='tender[lots][0][features][${num}][enum][${index}][option]']  ${element.title}
  \  ${value}  ukrtender_service.convert_float_to_string  ${element.value}
  \  Input Text     xpath=//*[@name='tender[lots][0][features][${num}][enum][${index}][value]']    ${value}
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'  Click Element  xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword If  '${TEST_NAME}' == 'Можливість додати неціновий показник на перший лот'    Run Keyword And Ignore Error  Редагувати закупівлю
  
Додати нецінову опцію
  [Arguments]  ${enum}  ${index}
  ${enum_value}=   ukrtender_service.convert_float_to_string  ${enum.value}
  Input Text   xpath=//*[@name='tender[nonprices][0][enum][${index}][option]']  ${enum.title}
  ${value}  ukrtender_service.convert_float_to_string  ${enum_value}
  Input Text   xpath=//*[@name='tender[nonprices][0][enum][${index}][value]']   ${value}


Додати нецінові критерії2
  [Arguments]  ${tender_data}
  ${features}=   Get From Dictionary   ${tender_data.data}   features
  ${features_length}=   Get Length   ${features}
  ${i}  Set Variable  ${0}
  :FOR   ${index}   IN RANGE   ${features_length}
  \   Log Many  CAT888 ${features[${index}].featureOf}
  \   Run Keyword If  '${features[${index}].featureOf}' == 'tenderer'   ukrtender.Додати неціновий показник на тендер при створенні  ${EMPTY}  ${EMPTY}  ${features}
  \   Run Keyword If  '${features[${index}].featureOf}' == 'item'   ukrtender.Додати неціновий показник на предмет при створенні  ${EMPTY}  ${EMPTY}  ${features}  ${EMPTY}
  \   Run Keyword If  '${features[${index}].featureOf}' == 'lot'   ukrtender.Додати неціновий показник на лот при створенні  ${EMPTY}  ${EMPTY}  ${features}  ${EMPTY}


Додати нецінові критерії
  [Arguments]  ${tender_data}
  ${features}=   Get From Dictionary   ${tender_data.data}   features
  ${features_length}=   Get Length   ${features}
  ${i}  Set Variable  ${0}
  :FOR   ${index}   IN RANGE   ${features_length}
  \   Run Keyword If  '${features[${index}].featureOf}' == 'tenderer'   Run Keywords
  ...   Дочекатися І Клікнути   xpath=//*[@id='edit-tender-multinonprices']
  ...   AND   Додати показник   ${features[${index}]}  ${tender_data}  ${i}
  ...   AND   ${i}  Set Variable  ${i+1}
  
Додати показник
  [Arguments]   ${features}  ${tender_data}  ${feature_index}  
  ${enum_length}=  Get Length   ${features.enum}
  Input Text  xpath=//*[@name='tender[nonprices][${feature_index}][feature_name]']  ${features.title}
  Input Text  xpath=//*[@name='tender[nonprices][${feature_index}][feature_description]']  ${features.description}
  Run Keyword If   '${mode}' == 'openeu'  Run Keywords
  ...  Input text   xpath=//input[@name="Tender[features][${feature_index}][title_en]"]  ${feature.title_en}
  ...  AND  Input text   name=Tender[features][${feature_index}][description_en]   ${feature.description}
  :FOR   ${index}   IN RANGE   ${enum_length}
  \   Run Keyword if   ${index} != 0   Дочекатися І Клікнути   xpath=//*[@id='edit-tender-multinonprice-item-0-option']
  \   Додати опцію   ${features.enum[${index}]}   ${index}   ${feature_index}
  
Index Should Not Be Zero
  [Arguments]  ${feature_index}
  ${element_id}=  Get Element Attribute  xpath=(//input[@class="feature_title" and not (contains(@name, "__EMPTY_FEATURE__"))])[${feature_index}]@id
  Should Not Be Equal As Integers  ${element_id.split("-")[1]}  0

Get Last Feature Index
  ${features_length}=  Get Matching Xpath Count  (//input[@class="feature_title" and not (contains(@name, "__EMPTY_FEATURE__"))])
  ${features_length}=  Convert To Integer  ${features_length}
  :FOR  ${f_index}  IN RANGE  ${features_length}
  \  ${element_id}=  Get Element Attribute  xpath=(//input[@class="feature_title" and not (contains(@name, "__EMPTY_FEATURE__"))])[${f_index + 1}]@id
  \  ${feature_title_value}=  Get Element Attribute  xpath=(//input[@class="feature_title" and not (contains(@name, "__EMPTY_FEATURE__"))])[${f_index + 1}]@value
  \  Run Keyword If  "${feature_title_value}" == "" and "${element_id.split("-")[1]}" == "0"  Wait Until Keyword Succeeds  10 x  2 s  Index Should Not Be Zero  ${f_index + 1}
  \  Return From Keyword If  "${feature_title_value}" == ""  ${element_id.split("-")[1]}
  
Додати опцію
  [Arguments]  ${enum}  ${index}  ${feature_index}
  ${enum_value}=   ukrtender_service.convert_float_to_string  ${enum.value}
  Log Many  CAT888 xpath=//*[@name='tender[nonprices][0][enum][${index}][option]']
  Log Many  CAT888 xpath=//*[@name='tender[nonprices][0][enum][${index}][value]']
  Scroll To Element  xpath=//*[@name='tender[nonprices][0][enum][${index}][option]']
  Input Text   xpath=//*[@name='tender[nonprices][0][enum][${index}][option]']  ${enum.title}
  ${value}  ukrtender_service.convert_float_to_string  ${enum_value}
  Input Text   xpath=//*[@name='tender[nonprices][0][enum][${index}][value]']   ${value}

  
Отримати інформацію із нецінового показника
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${field_name}
  Switch browser    ${username}
  Sleep  3
  
  ${value}=    subkeywords.Отримати дані з поля feature    ${field_name}  ${feature_id}
  ${value}=  Run Keyword If  '${field_name}' == 'featureOf'    ukrtender_service.convert_data_feature  ${value}
  ...        ELSE    Set Variable    ${value}
  [return]  ${value}


Видалити неціновий показник
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Можливість видалити неціновий показник на предмет'    Видалити неціновий показник на предмет  ${username}  ${tender_uaid}  ${feature_id}
  Run Keyword If    '${TEST_NAME}' == 'Можливість видалити неціновий показник на лот'    Видалити неціновий показник на лот  ${username}  ${tender_uaid}  ${feature_id}
  Run Keyword If    '${TEST_NAME}' == 'Можливість видалити неціновий показник на тендер'    Видалити неціновий показник на тендер  ${username}  ${tender_uaid}  ${feature_id}
  
Видалити неціновий показник на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}
  Sleep  3
  :FOR    ${INDEX}    IN RANGE    1    45
  \  ${found}  Run Keyword And Return Status  Element Should Be Visible  xpath=//a[@data-prozorro-title-id='${feature_id}' and (contains(.,'-Видалити неціновий критерій'))]
  \  Exit For Loop If  ${found}
  \  Sleep  5
  Дочекатися І Клікнути  xpath=//a[@data-prozorro-title-id='${feature_id}' and (contains(.,'-Видалити неціновий критерій'))]
  Дочекатися І Клікнути               xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword And Ignore Error  Редагувати закупівлю

Видалити неціновий показник на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}
  Sleep  3
  :FOR    ${INDEX}    IN RANGE    1    45
  \  ${found}  Run Keyword And Return Status  Element Should Be Visible  xpath=//a[@data-prozorro-title-id='${feature_id}' and (contains(.,'-Видалити неціновий критерій'))]
  \  Exit For Loop If  ${found}
  \  Sleep  5
  Дочекатися І Клікнути  xpath=//a[@data-prozorro-title-id='${feature_id}' and (contains(.,'-Видалити неціновий критерій'))]
  Дочекатися І Клікнути               xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword And Ignore Error  Редагувати закупівлю

Видалити неціновий показник на лот
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Scroll To Element  xpath=//*[text()="Додати лот"]
  :FOR    ${INDEX}    IN RANGE    1    50
  \  ${found}  Run Keyword And Return Status  Element Should Be Visible  xpath=//a[@data-prozorro-title-id='${feature_id}' and (contains(.,'-Видалити неціновий критерій'))]
  \  Exit For Loop If  ${found}
  \  Sleep  5
  Дочекатися І Клікнути  xpath=//a[@data-prozorro-title-id='${feature_id}' and (contains(.,'-Видалити неціновий критерій'))]
  Дочекатися І Клікнути               xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword And Ignore Error  Редагувати закупівлю
  

#                                    QUESTION                                               #

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}
  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Switch Browser    ${username}
  Sleep  5
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_2"]' ).trigger( 'click' )
  Click Element    xpath=//a[@id='tender-question-list-question-create-button-popup']
  Input Text                          xpath=//*[@name="question[title]"]  ${title}
  Input Text                          xpath=//*[@name="question[description]"]  ${description}
  Sleep  5
  Дочекатися І Клікнути                       xpath=//button[contains(.,"Створити питання")]
  Sleep  5

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}

  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Switch Browser    ${username}
  Sleep  5
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_2"]' ).trigger( 'click' )
#cat  Дочекатися І Клікнути    xpath=//a[@href="#tabs_desc_407_2"]
  Дочекатися І Клікнути    xpath=//a[@id='tender-question-list-question-create-button-popup']
  ${ques}=   Get Value  xpath=//option[@data-index="3"]
  Log Many  CAT ${ques}
  Select From List By Value  xpath=//*[@name='question[type]']  ${ques}
  Input Text                          xpath=//*[@name="question[title]"]  ${title}
  Input Text                          xpath=//*[@name="question[description]"]  ${description}
  Sleep  5
  Click Element                       xpath=//button[text()="Створити питання"]
  Sleep  5


Задати запитання на лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${question}

  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Switch Browser    ${username}
  Sleep  5
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_2"]' ).trigger( 'click' )
  Execute Javascript    $("#tender-question-list-question-create-button-popup").trigger("click")
  ${ques}=   Get Value  xpath=//option[@data-index="2"]
  Log Many  CAT ${ques}
  Select From List By Value  xpath=//*[@name='question[type]']  ${ques}
  Input Text                          xpath=//*[@name="question[title]"]  ${title}
  Input Text                          xpath=//*[@name="question[description]"]  ${description}
  Sleep  5
  Click Element                       xpath=//button[text()="Створити питання"]
  Sleep  5


Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
  Switch Browser   ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
#cat  Execute Javascript    $( 'a[href="#tabs_desc_407_2"]' ).trigger( 'click' )
  Дочекатися І Клікнути      xpath=//span[text()='Питання та відповіді']
  ${field_xpath}=    get_xpath.get_question_xpath    ${field_name}    ${question_id}
  Log Many  CAT field_xpath= ${field_xpath}
  Wait Until Keyword Succeeds  5 x  20 s  Run Keywords
  ...  Reload Page
  ...  AND    Дочекатися І Клікнути      xpath=//span[text()='Питання та відповіді']
  ...  AND  Wait Until Element Is Visible  xpath=${field_xpath}

  ${value}=    Get Text    xpath=${field_xpath}
  [return]  ${value}

Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
  ${answer}=     Get From Dictionary    ${answer_data.data}    answer
  Switch Browser    ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${tender_status}=    Get Value    xpath=//*[@name='tender[status]']
  Run Keyword If  '${tender_status}' != 'active.enquiries' and '${mode}' == 'belowThreshold'  Fail    "Період уточнень закінчився"
  # поставить проверку для опен
  Дочекатися І Клікнути      xpath=//span[text()='Питання та відповіді']
  Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For QuestionID   ${question_id}
#cat  :FOR    ${INDEX}    IN RANGE    1    2
#cat  \  Sleep  5
#cat  \  Reload Page
#cat  \  Дочекатися І Клікнути                       xpath=//span[text()='Питання та відповіді']
  Click Element                      xpath=//a[contains(@data-prozorro-id,'${question_id}')]
  Input Text    xpath=//textarea[@name="answer[description]"]    ${answer}
  Sleep  2
  Дочекатися І Клікнути    xpath=//button[@id='tender-question-list-add-answer-button']
#  Дочекатися І Клікнути                      xpath=//button[text()="Дати відповідь"]

#                                CLAIMS                                 #

Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  2
  Дочекатися І Клікнути    xpath=//a[@id='tender-complaint-edit-button-popup']
  Wait Until Element Is Visible    xpath=//select[@id='complaint-edit-dialog-type']    30
  Input Text    xpath=//input[@name='complaint[title]']    ${claim.data.title}
  Input Text    xpath=//textarea[@id='complaint-edit-dialog-description']    ${claim.data.description}
  Дочекатися І Клікнути    xpath=//button[contains(.,'Створити вимогу / скаргу')]


Створити чернетку про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}
  Switch browser    ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  Дочекатися І Клікнути    xpath=//a[@id='tender-complaint-edit-button-popup']
  ${lot1}=   Convert To String     Лот 1
  Run Keyword If    '${TEST_NAME}' == 'Можливість створити і подати вимогу про виправлення умов лоту'    Select From List By Value  xpath=//select[@id='complaint-edit-dialog-type']  ${lot1}
  Input Text    xpath=//input[@id='complaint-edit-dialog-title']    ${claim.data.title}
  Input Text    xpath=//textarea[@id='complaint-edit-dialog-description']    ${claim.data.description}
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//input[@id='complaint-edit-dialog-document']    ${document}
  Run Keyword If    '${document}' != '${None}'    ${list-document}=  Цінова пропозиція
  Run Keyword If    '${document}' != '${None}'    Select From List By Label  xpath=//select[@id='complaint-edit-dialog-document-type']    ${list-document}

  Дочекатися І Клікнути    xpath=//button[contains(.,'Створити вимогу / скаргу')]
  Sleep  30
  ${type}=  Set Variable If    'закупівлі' in '${TEST_NAME}'    tender
  ...                          'лоту' in '${TEST_NAME}'    lot
  ${complaintID}=    ukrtender_service.convert_complaintID    ${tender_uaid}    ${type}
  Sleep  9
  [return]  ${complaintID}


Створити вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${document}=${None}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  2
  Wait Until Keyword Succeeds  300 s  20 s  subkeywords.Wait For ComplaintButton
  Дочекатися І Клікнути    xpath=//a[@id='tender-complaint-edit-button-popup']
  Sleep  5
  #Wait Until Element Is Visible    xpath=//span[text()='Обрати']    30
  Input Text    xpath=//input[@id='complaint-edit-dialog-title']    ${claim.data.title}
  Input Text    xpath=//textarea[@id='complaint-edit-dialog-description']    ${claim.data.description}
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//input[@id='complaint-edit-dialog-document']    ${document}
  Run Keyword If    '${document}' != '${None}'    Sleep  10

  Дочекатися І Клікнути    xpath=//button[contains(.,'Створити вимогу / скаргу')]
  Sleep  19
  ${complaintID}=   Get Element Attribute   xpath=//h3[contains(text(),"${claim.data.title}")]@data-complaint-id
  Sleep  9
  Дочекатися І Клікнути    xpath=//a[contains(.,'Опубліковати') and contains(@data-complaint-id,'${complaintID}')]
  Sleep  5
  ${complaint_select}=   Convert To String     complaint
  Run Keyword If    '${TEST_NAME}' == 'Можливість створити скаргу про виправлення визначення переможця'    Select From List By Value  xpath=//select[@id='complaint-edit-dialog-claimtype']  ${complaint_select}
  Дочекатися І Клікнути    xpath=//button[@id='tender-complaint-edit-button']
  Sleep  30

  [return]  ${complaintID}


Створити вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}  ${document}=${None}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Keyword Succeeds  300 s  20 s  subkeywords.Wait For ComplaintButton
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  2
  Дочекатися І Клікнути    xpath=//a[@id='tender-complaint-edit-button-popup']
  Sleep  5
  #Wait Until Element Is Visible    xpath=//span[text()='Обрати']    30
  ${lot1}=   Convert To String     Лот 1
  Run Keyword If    '${TEST_NAME}' == 'Можливість створити і подати вимогу про виправлення умов лоту'    Select From List By Value  xpath=//select[@id='complaint-edit-dialog-type']  ${lot1}
  Input Text    xpath=//input[@id='complaint-edit-dialog-title']    ${claim.data.title}
  Input Text    xpath=//textarea[@id='complaint-edit-dialog-description']    ${claim.data.description}
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//input[@id='complaint-edit-dialog-document']    ${document}
  Run Keyword If    '${document}' != '${None}'    Sleep  10

  Дочекатися І Клікнути    xpath=//button[contains(.,'Створити вимогу / скаргу')]
  Sleep  5
  ${complaintID}=   Get Element Attribute   xpath=//h3[contains(text(),"${claim.data.title}")]@data-complaint-id
  Sleep  9
  Дочекатися І Клікнути    xpath=//a[contains(.,'Опубліковати') and contains(@data-complaint-id,'${complaintID}')]
  Sleep  5
  Дочекатися І Клікнути    xpath=//button[@id='tender-complaint-edit-button']
  Sleep  30

  [return]  ${complaintID}


Створити вимогу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  claim
  ...      ${ARGUMENTS[3]} ==  award_index
  ...      ${ARGUMENTS[4]} ==  document
  Switch browser    ${ARGUMENTS[0]}
  ${complaintID}=   ukrtender.Створити вимогу про виправлення умов закупівлі  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}  ${ARGUMENTS[2]}  ${ARGUMENTS[4]}
  [return]  ${complaintID}

  
Створити скаргу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  claim
  ...      ${ARGUMENTS[3]} ==  award_index
  ...      ${ARGUMENTS[4]} ==  document
  Switch browser    ${ARGUMENTS[0]}
  ${complaintID}=   ukrtender.Створити вимогу про виправлення умов закупівлі  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}  ${ARGUMENTS[2]}  ${ARGUMENTS[4]}
  [return]  ${complaintID}


Завантажити документацію до вимоги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${document}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
  Wait Until Element Is Visible    xpath=//*[text()='${complaintID}']    30
  Click Element    xpath=//a[contains(@class,'tender-complaint-list-title-link') and contains(@data-complaint-id,'${complaintID}')]
  Choose File       xpath=//input[@id='complaint-edit-dialog-document']    ${document}
  Sleep  10
  Дочекатися І Клікнути    xpath=//button[contains(.,'Редагувати вимогу / скаргу')]


Завантажити документацію до вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${award_index}  ${document}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
  Wait Until Element Is Visible    xpath=//*[text()='${complaintID}']    30
  Click Element    xpath=//a[contains(@class,'tender-complaint-list-title-link') and contains(@data-complaint-id,'${complaintID}')]
  Choose File       xpath=//input[@id='complaint-edit-dialog-document']    ${document}
  Sleep  10
  Дочекатися І Клікнути    xpath=//button[contains(.,'Редагувати вимогу / скаргу')]


Відповісти на вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  Switch browser    ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  Wait Until Keyword Succeeds  10 x  60 s  Run Keywords
  ...  Reload Page
  ...  AND  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
  ...  AND  Page Should Contain  ${complaintID}
  
  Дочекатися І Клікнути    xpath=//h3[contains(@data-complaint-id,'${complaintID}')]
  Дочекатися І Клікнути    xpath=//a[contains(.,'Відповісти на вимогу') and contains(@data-complaint-id,'${complaintID}')]
  Sleep  5
  #Wait Until Element Is Visible    xpath=//span[text()='Обрати']    30
  Select From List By Value  xpath=//select[@name='complaint_answer[resolution_type]']  ${answer_data.data.resolutionType}
  Sleep  2
  Input Text    xpath=//textarea[@name='complaint_answer[resolution]']    ${answer_data.data.resolution}
  Input Text    xpath=//textarea[@name='complaint_answer[decision]']    ${answer_data.data.tendererAction}

  Дочекатися І Клікнути    xpath=//button[@id='tender-complaint-answer-submit']
  Sleep  5

Відповісти на вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  ukrtender.Відповісти на вимогу про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}

Відповісти на вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}  ${award_index}
  ukrtender.Відповісти на вимогу про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}


Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  Дочекатися І Клікнути    xpath=//h3[contains(@data-complaint-id,'${complaintID}')]
  Дочекатися І Клікнути    xpath=//a[contains(.,'Оцінити відповідь') and contains(@data-complaint-id,'${complaintID}')]
  ${value}=  Set Variable If  '${confirmation_data.data.satisfied}'  Задоволен  Не задоволен
  Select From List By Label  xpath=//select[@id='tender-complaint-satisfied-dialog-form-satisfied']  ${value}
  Дочекатися І Клікнути    xpath=//button[@id='tender-complaint-satisfied-submit']
  Sleep  10


Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  ukrtender.Підтвердити вирішення вимоги про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}


Підтвердити вирішення вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}
  ukrtender.Підтвердити вирішення вимоги про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}


Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  Дочекатися І Клікнути    xpath=//h3[contains(@data-complaint-id,'${complaintID}')]
  Дочекатися І Клікнути    xpath=//a[contains(.,'Відмінити') and contains(@data-complaint-id,'${complaintID}')]
  Input Text    xpath=//textarea[@name='complaint_cancel[reason]']    ${cancellation_data.data.cancellationReason}
  Дочекатися І Клікнути    xpath=//button[@id='tender-complaint-cancel-submit']

  
Скасувати вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Switch browser  ${username}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  Дочекатися І Клікнути    xpath=//h3[contains(@data-complaint-id,'${complaintID}')]
  Дочекатися І Клікнути    xpath=//a[contains(.,'Відмінити') and contains(@data-complaint-id,'${complaintID}')]
  Input Text    xpath=//textarea[@name='complaint_cancel[reason]']    ${cancellation_data.data.cancellationReason}
  Дочекатися І Клікнути    xpath=//button[@id='tender-complaint-cancel-submit']


Скасувати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}
  Switch browser  ${username}
  ukrtender.Скасувати вимогу про виправлення умов закупівлі  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}


Отримати інформацію із скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}=${None}
  Switch Browser   ${username}

  Run Keyword If    "${TEST_NAME}" == "Відображення кінцевих статусів двох останніх вимог"    Sleep  290
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Execute JavaScript                  window.scrollTo(0, 0)
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ComplaintID   ${ComplaintID}
  ${index_complaint}=  Get Element Attribute  xpath=//input[contains(@value,"${complaintID}")]@id
  ${complaint_index}=  split_complaint  ${index_complaint}
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimTender   ${complaint_index}
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги про виправлення умов закупівлі"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimTender
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги про виправлення умов лоту"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimLot

  Sleep  3
  Дочекатися І Клікнути    xpath=//h3[@id='tender-complaint-list-title-${complaint_index}']
  Run Keyword If    "${TEST_NAME}" == "Можливість відповісти на вимогу про виправлення умов закупівлі"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Answered   ${complaint_index}
  Run Keyword If    "${TEST_NAME}" == "Можливість відповісти на вимогу про виправлення умов лоту"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Answered   ${complaint_index}
  Run Keyword If    "Відображення статусу 'answered'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Answered   ${complaint_index}
  Run Keyword If    "${TEST_NAME}" == "Відображення задоволення вимоги"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied   ${complaint_index}
  Run Keyword If    "${TEST_NAME}" == "Відображення незадоволення вимоги"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied   ${complaint_index}
  Run Keyword If    "Відображення статусу 'resolved'" in "${TEST_NAME}"     Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied   ${complaint_index}
  Run Keyword If    "Відображення статусу 'cancelled'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Cancelled   ${complaint_index}
  Run Keyword If    "Відображення статусу 'ignored'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Ignored   ${complaint_index}
  Run Keyword If    "Відображення статусу 'stopping'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Stopping   ${complaint_index}
  ${return_value}=  Run Keyword If    '${field_name}' == 'status'    Get Value  xpath=//input[@id='tender-complaint-list-status-${complaint_index}']
  ...    ELSE IF                      '${field_name}' == 'resolutionType'    Get Element Attribute  xpath=//span[@id='tender-complaint-list-resolutiontype-${complaint_index}']@data-value
  ...    ELSE IF                      '${field_name}' == 'satisfied'    Get Value  xpath=//input[@id='tender-complaint-list-satisfied-${complaint_index}']
  ...    ELSE IF                      '${field_name}' == 'complaintID'    Set Variable    ${complaintID}
  ...    ELSE IF                      '${field_name}' == 'title'    Get Text  xpath=//h3[@id='tender-complaint-list-title-${complaint_index}']
  ...    ELSE IF                      '${field_name}' == 'description'    Get Text  xpath=//span[@id='tender-complaint-list-description-${complaint_index}']
  ...    ELSE IF                      '${field_name}' == 'resolution'    Get Text  xpath=//span[@id='tender-complaint-list-resolution-${complaint_index}']
  ...    ELSE IF                      '${field_name}' == 'cancellationReason'    Get Text  xpath=//span[@id='tender-complaint-list-reason-${complaint_index}']
  ${return_value}=  Run Keyword If    '${field_name}' == 'title'    split_str1  ${return_value}
  ...    ELSE IF                      '${field_name}' == 'resolution'    split_str1  ${return_value}
  ...    ELSE IF                      '${return_value}' == '1'    Convert To Boolean  True
  ...    ELSE                         Set Variable    ${return_value}
  [return]  ${return_value}
  

Отримати інформацію із документа до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${field_name}  ${award_id}=${None}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  ${index_complaint}=  Get Element Attribute  xpath=//input[contains(@value,"${complaintID}")]@id
  ${complaint_index}=  split_complaint  ${index_complaint}
  Sleep  3
  Дочекатися І Клікнути    xpath=//h3[@id='tender-complaint-list-title-${complaint_index}']
  Wait Until Element Is Visible    xpath=//a[contains(text(), '${doc_id}')]    30  
  Sleep  3
  ${value}=    Get Text    xpath=//*[contains(text(), '${doc_id}')]
  [return]  ${value}


Отримати документ до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${award_id}=${None}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute Javascript    $( 'a[href="#tabs_desc_407_3"]' ).trigger( 'click' )
#cat  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//span[contains(.,'Вимоги')]
  ${index_complaint}=  Get Element Attribute  xpath=//input[contains(@value,"${complaintID}")]@id
  ${complaint_index}=  split_complaint  ${index_complaint}
  Sleep  3
  Дочекатися І Клікнути    xpath=//h3[@id='tender-complaint-list-title-${complaint_index}']
  Wait Until Element Is Visible    xpath=//a[contains(text(), '${doc_id}')]    30

  Sleep  3
  ${url_doc}=    Get Element Attribute    xpath=//a[contains(text(), '${doc_id}')]@href
  ${file_name}=    Get Text    xpath=//a[contains(text(), '${doc_id}')]
  ${file_name}=    Convert To String    ${file_name}
  ukrtender_service.download_file    ${url_doc}    ${file_name}    ${OUTPUT_DIR}
  [return]  ${file_name}

#                               BID OPERATIONS                          #

Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}=${None}  ${features_ids}=${None}
  Switch browser  ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${tender_status}=  Get Value  xpath=//*[@name="tender[status]"]
  Run Keyword If  '${tender_status}' == 'active.enquiries'  Fail  "Неможливо подати цінову пропозицію в період уточнень"
  Дочекатися І Клікнути    xpath=//*[text()="Створити пропозицію"]

  Run Keyword If    '${mode}' == 'belowThreshold'    subkeywords.Подати цінову пропозицію для below    ${bid}
  Run Keyword If    '${mode}' == 'openua'    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}
  Run Keyword If    '${mode}' == 'openeu'    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}
  Run Keyword If    '${mode}' == 'openua_defense'    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}
  Run Keyword If    '${mode}' == 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію першим учасником на другому етапі"    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}
  Run Keyword If    '${mode}' == 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію другим учасником на другому етапі"    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}
  Run Keyword If    '${mode}' == 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію третім учасником на другому етапі"    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}
  Run Keyword If    '${mode}' == 'open_esco'    subkeywords.Подати цінову пропозицію для esco    ${bid}    ${lots_ids}    ${features_ids}
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Дочекатися І Клікнути    xpath=//input[@value='Подати пропозицію']
  Run Keyword If  "Неможливість подати цінову пропозицію без прив" in "${TEST_NAME}"  Fail  "Неможливість подати цінову пропозицію без прив’язки до лоту користувачем"
  Log Many  CAT888 ==${TEST_NAME}
  Log Many  CAT888bid ==${bid}
#cat для КД_en
#cat  Run Keyword If  '${SUITE NAME}' != 'Tests Files.Complaints' and '${mode}' == 'open_competitive_dialogue'    Run Keywords
#cat  ...  Run Keyword If  ${NUMBER_OF_LOTS} == 1 and '${DIALOGUE_TYPE}' == 'EU'   Set Suite Variable    @{ID}    ${lots_ids}
#cat  Run Keyword If  ${NUMBER_OF_LOTS}==1 and '${mode}' == 'open_competitive_dialogue' and '${DIALOGUE_TYPE}' == 'EU'  Set Suite Variable    @{ID}    ${lots_ids}
  Run Keyword If  '${mode}' in 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію першим учасником"  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' in 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію першим учасником"  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']
  Run Keyword If  '${mode}' in 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію першим учасником"  Дочекатися І Клікнути    xpath=//input[@class='edit-bid-lot-enable']
  Run Keyword If  '${mode}' in 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію другим учасником"  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' in 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію другим учасником"  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']
  Run Keyword If  '${mode}' in 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію другим учасником"  Дочекатися І Клікнути    xpath=//input[@class='edit-bid-lot-enable']
  Run Keyword If  '${mode}' in 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію третім учасником"  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' in 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію третім учасником"  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']
  Run Keyword If  '${mode}' in 'open_competitive_dialogue' and "${TEST_NAME}" == "Можливість подати пропозицію третім учасником"  Дочекатися І Клікнути    xpath=//input[@class='edit-bid-lot-enable']

  Run Keyword If  ${NUMBER_OF_LOTS}==1 and "Неможливість подати цінову пропозицію без прив" not in "${TEST_NAME}" and '${mode}' not in 'open_esco'  Дочекатися І Клікнути    xpath=//input[contains(@class,'purchase edit-bid-submit-button')]
  Run Keyword If  '${mode}' in 'open_esco'  Дочекатися І Клікнути    xpath=//input[contains(@value,'Подати пропозицію')]
  
Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword If    '${mode}' == 'belowThreshold'    subkeywords.Змінити цінову пропозицію below    ${fieldvalue}
  ...    ELSE IF    '${mode}' != 'belowThreshold'    subkeywords.Змінити цінову пропозицію open    ${fieldname}    ${fieldvalue}
  

Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element    xpath=//*[@id='mForm:proposalDeleteBtn']
  Click Element    xpath=//*[text='Видалити']
  Sleep  5

Завантажити документ в ставку
#cat  [Arguments]  ${path}  ${tender_uaid}  ${doc_type}=documents  ${doc_name}
  [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=documents  ${doc_name}=${None}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element    xpath=//*[text()="Редагувати пропозицію"]
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Дочекатися І Клікнути                       xpath=//a[contains(@id,'edit-bid-add-document')]
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Дочекатися І Клікнути                       xpath=//a[contains(@id,'edit-bid-lot-add-document-0')]
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Wait Until Element Is Visible  xpath=//select[contains(@name,'tender[document_type]')]  5
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Select From List By Value  xpath=//select[contains(@name,'tender[document_type]')]  commercialProposal
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Choose File       xpath=//*[@id='edit-bid-document']    ${path}
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Wait Until Element Is Visible  xpath=//a[contains(@class,'areaukrzak-delete-link purchase_button')]  15
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Дочекатися І Клікнути                       xpath=//button[@id='edit-bid-document-save']

  Run Keyword If  ${NUMBER_OF_LOTS}==1  Wait Until Element Is Visible  xpath=//select[contains(@name,'lot_document[document_type]')]  5
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Select From List By Value  xpath=//select[contains(@name,'lot_document[document_type]')]  commercialProposal
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Choose File       xpath=//*[@id='edit-bid-lot-document']    ${path}
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Wait Until Element Is Visible  xpath=//a[contains(@class,'areaukrzak-delete-link purchase_button')]  15
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Дочекатися І Клікнути                       xpath=//button[@id='edit-bid-lot-document-save']

  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Click Element    xpath=//input[contains(@class,'button_purchase edit-bid-submit-button')]
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Click Element    xpath=//input[contains(@class,'button_purchase edit-bid-submit-button')]
  
#cat  Select From List By Value  xpath=//*[@name='bid[document_type]']  commercialProposal
#cat  Sleep  2
#cat  Choose File       xpath=//*[@name="multifiles[]"]    ${path}
#cat  Sleep  10
#cat  Run Keyword If  ${NUMBER_OF_LOTS}==0  Click Element    xpath=//*[@value="Редагувати пропозицію"]
#cat  Run Keyword If  ${NUMBER_OF_LOTS}==1  Click Element    xpath=//input[@id='edit-bid-lot-add-0']
#cat  Sleep  25


Змінити документ в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${path}  ${doc_id}  ${doc_name}=${None}
#cat  [Arguments]  ${tender_uaid}  ${path}  ${doc_id}  ${doc_name}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element    xpath=//*[text()="Редагувати пропозицію"]
  Execute JavaScript                  window.scrollTo(0, 1000)
  Click Element    xpath=//a[contains(.,'${doc_id}')]
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Wait Until Element Is Visible  xpath=//select[contains(@name,'tender[document_type]')]  5
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Choose File       xpath=//*[@id='edit-bid-document']    ${path}
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Wait Until Element Is Visible  xpath=//a[contains(@class,'areaukrzak-delete-link purchase_button')]  15
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Дочекатися І Клікнути                       xpath=//button[@id='edit-bid-document-save']

  Run Keyword If  ${NUMBER_OF_LOTS}==1  Wait Until Element Is Visible  xpath=//select[contains(@name,'lot_document[document_type]')]  5
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Choose File       xpath=//*[@id='edit-bid-lot-document']    ${path}
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Wait Until Element Is Visible  xpath=//a[contains(@class,'areaukrzak-delete-link purchase_button')]  15
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Дочекатися І Клікнути                       xpath=//button[@id='edit-bid-lot-document-save']

  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Click Element    xpath=//input[contains(@class,'button_purchase edit-bid-submit-button')]
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Click Element    xpath=//input[contains(@class,'button_purchase edit-bid-submit-button')]
  Sleep  25


Змінити документацію в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${doc_data}  ${doc_id}  ${doc_name}=${None}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element    xpath=//*[text()="Редагувати пропозицію"]
  Execute JavaScript                  window.scrollTo(0, 800)
  Sleep  2
  Select From List By Value  xpath=//*[@name='bid[document_type]']  commercialProposal
  Sleep  2
  Choose File       xpath=//*[@name="multifiles[]"]        ${CURDIR}/Key-6.dat
  Sleep  10
  Click Element    xpath=//input[@id='edit-bid-document-private']
  Run Keyword If  ${NUMBER_OF_LOTS}==0  Click Element    xpath=//*[@value="Редагувати пропозицію"]
  Run Keyword If  ${NUMBER_OF_LOTS}==1  Click Element    xpath=//input[@id='edit-bid-lot-add-0']
  Sleep  25


Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${present}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//*[text()="Редагувати пропозицію"]
  Run Keyword If    ${present}    Click Element    xpath=//*[text()="Редагувати пропозицію"]
  Log Many  CAT111 ${present}
  Run Keyword If    "${TEST_NAME}" == "Відображення зміни статусу першої пропозиції після редагування інформації про тендер"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Status
  Run Keyword If    "${TEST_NAME}" == "Відображення зміни статусу другої пропозиції після редагування інформації про тендер"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Status
  ${return_value}=    Run Keyword If    '${mode}' == 'belowThreshold'    subkeywords.Отримати дані з bid below
  ...    ELSE IF                      '${mode}' != 'belowThreshold'    subkeywords.Отримати дані з bid open    ${field}
  [return]  ${return_value}


Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Switch Browser    ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible    xpath=//a[contains(@href,'https://auction-sandbox.prozorro.gov.ua/')]    30
  Sleep  2
  ${auction_url}=    Get Element Attribute    xpath=//a[contains(text(), 'https://auction-sandbox.prozorro.gov.ua/')]@href
  [return]  ${auction_url}


Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Switch Browser    ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible    xpath=//a[contains(@href,'https://auction-sandbox.prozorro.gov.ua/')]    30
  Sleep  2
  ${auction_url}=    Get Element Attribute    xpath=//a[contains(text(), 'https://auction-sandbox.prozorro.gov.ua/')]@href
  [return]  ${auction_url}


#                      QUALIFICATION OPERATIONS                     #

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  Log Many  CAT ${document} До ЕЦПdocument
  Log Many  CAT ${award_num}До ЕЦПaward_num
  ${award_num}=  Convert To Integer  ${award_num}
  Run Keyword If    ${award_num}==0   Wait Until Keyword Succeeds  300 s  20 s  subkeywords.Wait For AwardButton1
  Run Keyword If    ${award_num}==1   Wait Until Keyword Succeeds  300 s  20 s  subkeywords.Wait For AwardButton2
  Execute JavaScript                  window.scrollTo(0, 0)
  Run Keyword If    ${award_num}==0  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-award-item-go-button-1']
  Run Keyword If    ${award_num}==1  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-award-item-go-button-2']
  Run Keyword If    ${award_num}==2     Wait Until Keyword Succeeds  600 s  10 s  subkeywords.Wait For EscoButtonContract
  Run Keyword If    ${award_num}==2    Execute Javascript    $( "#edit-tender-award-item-go-button-3" ).trigger( 'click' )
  Run Keyword If    ${award_num}==2    Sleep  5
  ${qual_doc}=   Convert To String     Повідомлення про рішення
  Select From List By Label  xpath=//*[@id='edit-tender-dialog-award-qualification-form-document-type']  ${qual_doc}
  Sleep  2
  Choose File       xpath=//*[@name="multifiles[]"]    ${document}


Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Run Keyword If    ${award_num}==0   Wait Until Keyword Succeeds  300 s  20 s  subkeywords.Wait For AwardButton1
  Run Keyword If    ${award_num}==1   Wait Until Keyword Succeeds  300 s  20 s  subkeywords.Wait For AwardButton2
  Run Keyword If  '${mode}' in 'belowThreshold openua openeu open_esco open_competitive_dialogue openua_defense'   Run Keywords
  ...  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ...  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ...  AND  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  ...  AND  Run Keyword If    ${award_num}==2  Sleep  10
  ...  AND  Run Keyword If    ${award_num}==0  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-award-item-go-button-1']
  ...  AND  Run Keyword If    ${award_num}==1  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-award-item-go-button-2']
  ...  AND  Run Keyword If    ${award_num}==2  Execute Javascript    $( "#edit-tender-award-item-go-button-3" ).trigger( 'click' )
  ...  AND  Sleep  5
  ...  AND  Select From List By Label  xpath=//*[@id='edit-tender-dialog-award-qualification-form-document-type']  Повідомлення про рішення
  ...  AND  Sleep  2
  ...  AND  Choose File       xpath=//*[@name="multifiles[]"]    ${CURDIR}/Key-6.dat
  ...  AND  Sleep  10
  ${qual}=   Convert To String     Визнати переможцем
  Select From List By Label  xpath=//select[@id='edit-tender-dialog-award-qualification-form-action']  ${qual}
  Дочекатися І Клікнути  name=award_qualification[qualified]
  Дочекатися І Клікнути  name=award_qualification[eligible]
  Sleep  10
  Log Many  CAT До ЕЦП
  Дочекатися І Клікнути  xpath=//button[contains(.,'Підтвердити рішення')]
  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
   ...  Page Should Contain  Зверніть увагу
   ...  AND  Wait Element Animation  xpath=//*[contains(text(),"Накласти ЕЦП")]
  ${active}=  Execute Javascript  return quinta.callEcpCdn()
  Run Keyword If  (${active} == 0)  Накласти ЄЦП

Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Switch browser  ${username}
  :FOR    ${INDEX}    IN RANGE    1    15
  \  ${contract_button_is_visible}  Run Keyword And Return Status  Element Should Be Visible  xpath=//a[@id='edit-tender-award-item-go-button-2']
  \  Exit For Loop If  ${contract_button_is_visible}
  \  Sleep  15
  \  Reload Page
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  Run Keyword If  '${mode}' in 'belowThreshold open_esco'   Run Keywords
  ...  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ...  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ...  AND  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  ...  AND  Дочекатися І Клікнути  xpath=//a[@id='edit-tender-award-item-go-button-2']
  ...  AND  Select From List By Label  xpath=//*[@id='edit-tender-dialog-award-qualification-form-document-type']  Повідомлення про рішення
  ...  AND  Sleep  2
  ...  AND  Choose File       xpath=//*[@name="multifiles[]"]    ${CURDIR}/Key-6.dat
  ...  AND  Sleep  10
#cat  ${qual}=   Convert To String     Учасник переговорів
  ${qual}=   Convert To String     Відхилити пропозицію
  Select From List By Label  xpath=//select[@id='edit-tender-dialog-award-qualification-form-action']  ${qual}
  Дочекатися І Клікнути  id=edit-tender-dialog-award-qualification-reason1
  Дочекатися І Клікнути  id=edit-tender-dialog-award-qualification-reason2
  Input Text  xpath=//input[@id='edit-tender-dialog-award-qualification-title']  отказ
  Input Text  xpath=//textarea[@id='edit-tender-dialog-award-qualification-description']  отказ
  Sleep  10
  Дочекатися І Клікнути  xpath=//button[contains(.,'Підтвердити рішення')]
  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
   ...  Page Should Contain  Зверніть увагу
   ...  AND  Wait Element Animation  xpath=//*[contains(text(),"Накласти ЕЦП")]
  ${active}=  Execute Javascript  return quinta.callEcpCdn()
  Run Keyword If  (${active} == 0)  Накласти ЄЦП


Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Switch browser  ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Run Keyword If    ${award_num}==0   Wait Until Keyword Succeeds  300 s  20 s  subkeywords.Wait For EscapePrequalificationButton1
  Run Keyword If    ${award_num}==1   Wait Until Keyword Succeeds  300 s  20 s  subkeywords.Wait For EscapePrequalificationButton2
  Run Keyword If    ${award_num}==0  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-award-item-escape-button-1']
  Run Keyword If    ${award_num}==1  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-award-item-escape-button-2']
  Дочекатися І Клікнути  id=edit-tender-dialog-award-qualification-reason1
  Дочекатися І Клікнути  id=edit-tender-dialog-award-qualification-reason2
  Input Text  xpath=//input[@id='edit-tender-dialog-award-qualification-title']  отказ
  Input Text  xpath=//textarea[@id='edit-tender-dialog-award-qualification-description']  отказ
  Sleep  10
  Дочекатися І Клікнути  xpath=//button[contains(.,'Підтвердити рішення')]
  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
   ...  Page Should Contain  Зверніть увагу
   ...  AND  Wait Element Animation  xpath=//*[contains(text(),"Накласти ЕЦП")]
  ${active}=  Execute Javascript  return quinta.callEcpCdn()
  Run Keyword If  (${active} == 0)  Накласти ЄЦП
  Sleep  30
  


#                       LIMITED PROCUREMENT                          #

Створити постачальника, додати документацію і підтвердити його
  [Arguments]  ${username}  ${tender_uaid}  ${supplier_data}  ${document}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-supplier']
  Input Text  name=supplier[edrpou]  ${supplier_data.data.suppliers[0].identifier.id}
  Input Text  name=supplier[company]  ${supplier_data.data.suppliers[0].name}
  Wait And Select From List By Value  name=supplier[region]  ${supplier_data.data.suppliers[0].address.region}
  Input Text  name=supplier[postcode]  ${supplier_data.data.suppliers[0].address.postalCode}
  Input Text  name=supplier[locality]  ${supplier_data.data.suppliers[0].address.locality}
  Input Text  name=supplier[street]  ${supplier_data.data.suppliers[0].address.streetAddress}
  Input Text  name=supplier[fio]  ${supplier_data.data.suppliers[0].contactPoint.name}
  Input Text  name=supplier[phone]  ${supplier_data.data.suppliers[0].contactPoint.telephone}
  Input Text  name=supplier[email]  ${supplier_data.data.suppliers[0].contactPoint.email}
  Input Text  name=supplier[price]  ${supplier_data.data.value.amount}
  Run Keyword If  ${supplier_data.data.value.valueAddedTaxIncluded}  Дочекатися І Клікнути  xpath=//input[@name='supplier[vat]']
  Дочекатися І Клікнути  name=supplier[eligible]
  Дочекатися І Клікнути  name=supplier[qualified]
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-supplier-submit']
  
  Run Keyword If  '${MODE}' in 'negotiation reporting'     Wait Until Keyword Succeeds    120 s    20 s    subkeywords.Wait For QualificationButton
#cat  Reload Page
#cat  Sleep  5
#cat  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
#cat  Sleep  5
  
  Дочекатися І Клікнути  xpath=//a[contains(.,'Кваліфікація')]
  Wait And Select From List By Value  id=edit-tender-dialog-award-qualification-form-action  active
  Choose File       xpath=//input[@id='edit-tender-dialog-award-qualification-form-document']    ${document}
  Sleep  10
  ${qual_doc}=   Convert To String     Повідомлення про рішення
  Select From List By Label  xpath=//select[@id='edit-tender-dialog-award-qualification-form-document-type']  ${qual_doc}
  Дочекатися І Клікнути  xpath=//input[@name='award_qualification[qualified]']
#cat  Дочекатися І Клікнути  name=award_qualification[eligible]
  Дочекатися І Клікнути  xpath=//button[contains(.,'Підтвердити рішення')]
  ${active}=  Execute Javascript  return quinta.callEcpCdn()
  Run Keyword If  (${active} == 0)  Накласти ЄЦП
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-awards-cancel']


Створити постачальника, додати документацію і підтвердити його2
  [Arguments]  ${username}  ${tender_uaid}  ${supplier_data}  ${document}
  Switch browser  ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  jquery=span:contains('Оголосити')
  Click Element  xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()="Оголосити"]
  Wait Until Keyword Succeeds  3x  1  Wait Until Element Is Visible  xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]
  Click Element                       xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]
  :FOR    ${INDEX}    IN RANGE    1    10
  \  Sleep  10
  \  Reload Page
  \  ${bid_status}=  Get Text  xpath=//*[@id="mForm:status"]
  \  Exit For Loop If  '${bid_status}' == 'Активна'
  ${s}  Set Variable  ${supplier_data.data}
  Click Element  jquery=span:contains('Учасники закупівлі')
  Click Element  jquery=span:contains('Новий учасник')
  Click Element  id=mForm:tabs:cLot_label
  Wait Until Element Is Visible  id=mForm:tabs:cLot_1
  Click Element  id=mForm:tabs:cLot_1
  Input Text  id=mForm:tabs:amount  ${s.value.amount}
  Execute Javascript  window.scrollTo(0,600)
  Click Element  xpath=(//table[@id='mForm:tabs:limited_qualification']//span)[1]
  Sleep  1
  Choose File  id=mForm:tabs:tFile_input  ${document}
  Wait Until Element Is Visible  xpath=(//div[@id='mForm:docCard:docCard']//button)[1]
  Click Element  xpath=(//div[@id='mForm:docCard:docCard']//button)[1]
  Wait Until Element Is Visible  id=mForm:tabs:pnlFilesT
  Input Text  id=mForm:tabs:rName  ${s.suppliers[0].contactPoint.name}
  Input Text  id=mForm:tabs:rMail  ${s.suppliers[0].contactPoint.email}
  ${s.suppliers[0].contactPoint.telephone}  Get Substring  ${s.suppliers[0].contactPoint.telephone}  0  13
  Input Text  id=mForm:tabs:rPhone  ${s.suppliers[0].contactPoint.telephone}
  Input Text  id=mForm:tabs:orgTin_input  ${s.suppliers[0].identifier.id}
  Click Element  xpath=(//table[@id='mForm:tabs:orgIsGos']//span)[1]
  ${s.suppliers[0].name}  Get Substring  ${s.suppliers[0].name}  0  50  # line limit
  Input Text  id=mForm:tabs:orgName  ${s.suppliers[0].name}
  Input Text  id=mForm:tabs:orgNameFull  ${s.suppliers[0].identifier.legalName}
  Input Text  id=mForm:tabs:zipCode  ${s.suppliers[0].address.postalCode}
  ${s.suppliers[0].address.region}  ukrtender_service.get_delivery_region  ${s.suppliers[0].address.region}
  Input Text  id=mForm:tabs:orgCReg_input  ${s.suppliers[0].address.region}
  Wait Until Element Is Visible  id=mForm:tabs:orgCReg_panel
  Click Element  xpath=(//div[@id='mForm:tabs:orgCReg_panel']//tr)[1]
  ${s.suppliers[0].address.locality}  ukrtender_service.convert_locality  ${s.suppliers[0].address.locality}
  Input Text  id=mForm:tabs:orgCTer_input  ${s.suppliers[0].address.locality}
  Wait Until Element Is Visible  id=mForm:tabs:orgCTer_panel
  Click Element  xpath=(//div[@id='mForm:tabs:orgCTer_panel']//tr)[1]
  Input Text  id=mForm:tabs:orgAddr  ${s.suppliers[0].address.streetAddress}
  Click Element  jquery=span:contains('Зберегти')
  Wait Until Element Is Visible  id=notifyMess
  Element Should Contain  id=notifyMess  Збережено!
  Wait Until Element Is Not Visible  id=notifyMess
  Wait Until Element Is Visible  jquery=span:contains('Так'):nth(1)
  Click Element  jquery=span:contains('Так'):nth(1)
  Wait Until Element Is Visible  jquery=span:contains('Зареєструвати пропозицію')
  Click Element  jquery=span:contains('Зареєструвати пропозицію')
  Wait Until Element Is Visible  id=notifyMess
  Element Should Contain  id=notifyMess  Ваша пропозиція реєструється
  :FOR    ${INDEX}    IN RANGE    1    11
  \  ${bid_status}  Get Text  xpath=(//tbody/tr[4]/td[2])[1]
  \  Exit For Loop If  '${bid_status}' == 'Зареєстрована'
  \  Sleep  20
  \  Reload Page
  Click Element  jquery=span:contains('Оголосити переможцем')
  Wait Until Element Is Visible  jquery=span:contains('Так'):nth(6)
  Click Element  jquery=span:contains('Так'):nth(6)
  :FOR    ${INDEX}    IN RANGE    1    11
  \  Sleep  20
  \  Reload Page
  \  ${win}  Run Keyword And Return Status  Element Should Contain  xpath=(//tbody/tr[4]/td[2])[1]  Закупівлю виграв учасник
  \  Exit For Loop If  ${win}
  ${TENDER_UAID}  Get Text  id=mForm:tabs:nBid
  Set To Dictionary  ${TENDER}  TENDER_UAID=${TENDER_UAID}


Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
#cat#cat  Run Keyword If  '${MODE}' in 'belowThreshold'  Sleep  30
  Sleep  5
  ${contract_num}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  2
  ...  ELSE IF  "${SUITE_NAME}" == "Tests Files.Complaints" or '${MODE}' in 'belowThreshold reporting negotiation' or '${MODE}' == 'openua_defense'  Set Variable  0
  ...  ELSE  Set Variable  1
  Run Keyword If  '${MODE}' in 'belowThreshold reporting'     Wait Until Keyword Succeeds    120 s    20 s    subkeywords.Wait For ContractButton   ${contract_num}
  Дочекатися І Клікнути  xpath=//a[contains(.,'Підписати контракт') and contains(@data-index,"${contract_num}")]
#cat#cat  Sleep  15
  ${dc_input}  Evaluate  datetime.datetime.now().strftime("%d.%m.%Y %H:%M:%S")  datetime
  Input Text  xpath=//input[@name='activate_contract[number]']  777
  Run Keyword If  '${MODE}' not in 'openua openeu open_competitive_dialogue openua_defense'  Input Text  xpath=//input[@name='activate_contract[purchase_date]']  ${dc_input}
  Run Keyword If  '${MODE}' not in 'openua openeu open_competitive_dialogue openua_defense'  Input Text  name=activate_contract[start_date]  01.12.2018 00:00:00
  Run Keyword If  '${MODE}' not in 'openua openeu open_competitive_dialogue openua_defense'  Input Text  name=activate_contract[end_date]  09.12.2018 00:00:00
#cat  Input Text  name=activate_contract[total]  777777
  Дочекатися І Клікнути  xpath=//input[@name='activate_contract[confirm]']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-activate-contract-submit']
  ${active}=  Execute Javascript  return quinta.callEcpCdn()
  Run Keyword If  (${active} == 0)  Накласти ЄЦП



#                               OPEN PROCUREMENT                                #

Підтвердити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  :FOR   ${index}   IN RANGE    1    3
  \   Run Keyword If  ${qualification_num}==-1   Run Keywords
  ...  Sleep  5
  ...  AND  Reload Page
  \   Run Keyword If  ${qualification_num}==-2   Run Keywords
  ...  Sleep  5
  ...  AND  Reload Page
  \   Run Keyword If  ${qualification_num}==1   Run Keywords
  ...  Sleep  5
  ...  AND  Reload Page
  \   Run Keyword If  ${qualification_num}==0   Run Keywords
  ...  Sleep  5
  ...  AND  Reload Page
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${document}=  get_upload_file_path
  ${qualification_num}=  Convert To Integer  ${qualification_num}
  Run Keyword If    ${qualification_num}==0    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If    ${qualification_num}==0  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
#cat  Run Keyword If    ${qualification_num}==0  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-prequalification-qualification-go-button-0']
  Run Keyword If    ${qualification_num}==0  Execute Javascript    $( "#edit-tender-prequalification-qualification-go-button-0" ).trigger( 'click' )
  Run Keyword If    ${qualification_num}==0  Choose File       xpath=//*[@id="edit-tender-dialog-qualification-form-document"]    ${CURDIR}/Key-6.dat
  Run Keyword If    ${qualification_num}==1    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If    ${qualification_num}==1  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
#cat  Run Keyword If    ${qualification_num}==1  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-prequalification-qualification-go-button-1']
  Run Keyword If    ${qualification_num}==1  Execute Javascript    $( "#edit-tender-prequalification-qualification-go-button-1" ).trigger( 'click' )
  Run Keyword If    ${qualification_num}==1  Choose File       xpath=//*[@id="edit-tender-dialog-qualification-form-document"]    ${CURDIR}/Key-6.dat
  Run Keyword If    "${mode}" not in "open_competitive_dialogue open_esco" and ${qualification_num}==-1    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If    "${mode}" not in "open_competitive_dialogue open_esco" and ${qualification_num}==-1  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword If    "${mode}" not in "open_competitive_dialogue open_esco" and ${qualification_num}==-1  Wait Until Keyword Succeeds  300 s  20 s  subkeywords.Wait For PrequalificationButton2
  Run Keyword If    "${mode}" not in "open_competitive_dialogue open_esco" and ${qualification_num}==-1  Дочекатися І Клікнути    xpath=//*[@id='edit-tender-prequalification-qualification-go-button-2']
  Run Keyword If    "${mode}" not in "open_competitive_dialogue open_esco" and ${qualification_num}==-1  Choose File       xpath=//*[@id="edit-tender-dialog-qualification-form-document"]    ${CURDIR}/Key-6.dat
  Run Keyword If    ${qualification_num}==2    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If    ${qualification_num}==2  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
#cat   Run Keyword If    ${qualification_num}==2  Дочекатися І Клікнути    xpath=//*[@id='edit-tender-prequalification-qualification-go-button-2']
  Run Keyword If    ${qualification_num}==2  Execute Javascript    $( "#edit-tender-prequalification-qualification-go-button-2" ).trigger( 'click' )
  Run Keyword If    ${qualification_num}==2  Choose File       xpath=//*[@id="edit-tender-dialog-qualification-form-document"]    ${CURDIR}/Key-6.dat
  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-1    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-1  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
#cat  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-1  Дочекатися І Клікнути    xpath=//*[@id='edit-tender-prequalification-qualification-go-button-1']
  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-1  Execute Javascript    $( "#edit-tender-prequalification-qualification-go-button-1" ).trigger( 'click' )
  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-1  Choose File       xpath=//*[@id="edit-tender-dialog-qualification-form-document"]    ${CURDIR}/Key-6.dat
  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-2    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-2  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
#cat  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-2  Дочекатися І Клікнути    xpath=//*[@id='edit-tender-prequalification-qualification-go-button-2']
  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-2  Execute Javascript    $( "#edit-tender-prequalification-qualification-go-button-2" ).trigger( 'click' )
  Run Keyword If    "${mode}" == "open_competitive_dialogue" and ${qualification_num}==-2  Choose File       xpath=//*[@id="edit-tender-dialog-qualification-form-document"]    ${CURDIR}/Key-6.dat

  Run Keyword If    ${qualification_num}==-1 and '${MODE}' in 'open_esco'    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If    ${qualification_num}==-1 and '${MODE}' in 'open_esco'  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
#cat  Run Keyword If    ${qualification_num}==-1 and '${MODE}' in 'open_esco'  Дочекатися І Клікнути    xpath=//*[@id='edit-tender-prequalification-qualification-go-button-1']
  Run Keyword If    ${qualification_num}==-1 and '${MODE}' in 'open_esco'  Execute Javascript    $( "#edit-tender-prequalification-qualification-go-button-1" ).trigger( 'click' )
  Run Keyword If    ${qualification_num}==-1 and '${MODE}' in 'open_esco'  Choose File       xpath=//*[@id="edit-tender-dialog-qualification-form-document"]    ${CURDIR}/Key-6.dat
  ${qual_doc}=   Convert To String     Повідомлення про рішення
  Select From List By Label  xpath=//*[@id='edit-tender-dialog-qualification-form-document-type']  ${qual_doc}
  ${qual}=   Convert To String     active
#cat  ${qual}=   Run Keyword If    '${MODE}' in 'open_competitive_dialogue'  Convert To String     Допустити до переговорів
#cat  ...  ELSE  Convert To String     Допустити до аукціону
#cat  Select From List By Label  xpath=//*[@id='edit-tender-dialog-qualification-form-action']  ${qual}
  Select From List By Value  xpath=//*[@id='edit-tender-dialog-qualification-form-action']  ${qual}
  
  Дочекатися І Клікнути  name=qualification[permit]
  Дочекатися І Клікнути  name=qualification[law]
  Sleep  10
  Дочекатися І Клікнути  xpath=//button[contains(.,'Підтвердити')]
  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
   ...  Page Should Contain  Зверніть увагу
   ...  AND  Wait Element Animation  xpath=//*[contains(text(),"Накласти ЕЦП")]
  Дочекатися І Клікнути  xpath=//button[contains(.,'Накласти ЕЦП')]
  ${active}=  Execute Javascript  return quinta.callEcpCdn()
  Run Keyword If  (${active} == 0)  Накласти ЄЦП

Відхилити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Switch browser  ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${qualification_num}=  Convert To Integer  ${qualification_num}
#cat  Run Keyword If    ${qualification_num}==1  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword If    ${qualification_num}==1    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  Run Keyword If    ${qualification_num}==1  Click Element    xpath=//a[@id='edit-tender-prequalification-qualification-go-button-1']
  Run Keyword If    ${qualification_num}==1  Execute Javascript    $( "#edit-tender-prequalification-qualification-go-button-1" ).trigger( 'click' )
  ${qual}=   Run Keyword If    '${MODE}' in 'open_competitive_dialogue'  Convert To String     Відмовити в переговорах
  ...  ELSE  Convert To String     Відмовити в участі в аукціоні
  Select From List By Label  xpath=//select[@id='edit-tender-dialog-qualification-form-action']  ${qual}
  ${qual_doc}=   Convert To String     Повідомлення про рішення
  Select From List By Label  xpath=//*[@id='edit-tender-dialog-qualification-form-document-type']  ${qual_doc}
  Sleep  2
  Choose File       xpath=//*[@name="multifiles[]"]    ${CURDIR}/Key-6.dat
  Sleep  10
  Дочекатися І Клікнути   xpath=//input[@id='edit-tender-dialog-qualification-reason1']
  Input text              xpath=//textarea[@id='edit-tender-dialog-qualification-description']   відмова
  Sleep  10
  Log Many  CAT До ЕЦП
  Дочекатися І Клікнути  xpath=//button[contains(.,'Підтвердити')]
  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
   ...  Page Should Contain  Зверніть увагу
   ...  AND  Wait Element Animation  xpath=//*[contains(text(),"Накласти ЕЦП")]
  Дочекатися І Клікнути  xpath=//button[contains(.,'Накласти ЕЦП')]
  ${active}=  Execute Javascript  return quinta.callEcpCdn()
  Run Keyword If  (${active} == 0)  Накласти ЄЦП


Завантажити документ у кваліфікацію
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${qualification_num}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Log Many  CAT ${document} До ЕЦПdocument
  Log Many  CAT ${qualification_num}До ЕЦПqualification_num
  ${qualification_num}=  Convert To Integer  ${qualification_num}
#cat  Run Keyword If    ${qualification_num}==0  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-prequalification-qualification-go-button-0']
#cat  Run Keyword If    ${qualification_num}==1  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-prequalification-qualification-go-button-1']
  Run Keyword If    ${qualification_num}==0  Execute Javascript    $( "#edit-tender-prequalification-qualification-go-button-0" ).trigger( 'click' )
  Run Keyword If    ${qualification_num}==1  Execute Javascript    $( "#edit-tender-prequalification-qualification-go-button-1" ).trigger( 'click' )
  ${qual_doc}=   Convert To String     Повідомлення про рішення
  Select From List By Label  xpath=//*[@id='edit-tender-dialog-qualification-form-document-type']  ${qual_doc}
  Sleep  2
  Choose File       xpath=//*[@id="edit-tender-dialog-qualification-form-document"]    ${document}
  Sleep  10


Скасувати кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Switch browser  ${username}
  ${qualification_num}=  Convert To Integer  ${qualification_num}
#cat  Run Keyword If    ${qualification_num}==1  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Run Keyword If    ${qualification_num}==1    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
  Run Keyword If    ${qualification_num}==1  Sleep  2
  Run Keyword If    ${qualification_num}==1    Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
  Run Keyword If    ${qualification_num}==1  Дочекатися І Клікнути    xpath=//a[@id='edit-tender-prequalification-qualification-escape-button-1']

  Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
   ...  Page Should Contain  Зверніть увагу
   ...  AND  Wait Element Animation  xpath=//*[contains(text(),"Накласти ЕЦП")]
  Sleep  2
  Дочекатися І Клікнути  xpath=//button[contains(.,'Накласти ЕЦП')]
  ${active}=  Execute Javascript  return quinta.callEcpCdn()
  Run Keyword If  (${active} == 0)  Накласти ЄЦП

Затвердити остаточне рішення кваліфікації
  [Arguments]  ${username}  ${tender_uaid}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Sleep  2
  Дочекатися І Клікнути  xpath=//a[contains(.,'Сформувати протокол прекваліфікації')]
  Sleep  1
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-qualification-propose-save-protocol-submit']
  Sleep  5


Перевести тендер на статус очікування обробки мостом
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser  ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//input[@id='edit-tender-active-stage2-pending-button']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-propose-stage2-submit']
  
Отримати тендер другого етапу та зберегти його
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser  ${username}
  Click Element  xpath=//nav[@id="site-navigation"]/descendant::a[@class="menu-tenders"]
  Click Element            xpath=//input[@id='purchase_list_search1']
  Input Text                       xpath=//input[@id='purchase_list_search1']    ${tender_uaid}
  Click Element  xpath=//input[@id='purchase-button-search-1']
  ${TENDER_UAID_second_stage}=  Get Element Attribute  xpath=//a[contains(@href,'http://test.ukrtender.com.ua/tender-detail/?id=')]@data-tenderid
	
Отримати доступ до тендера другого етапу
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser  ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}


Активувати другий етап
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser  ${username}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//a[@id='edit-tender-redirect-stage1-button']
  Дочекатися І Клікнути  xpath=//input[@id='edit-tender-go-stage2-button']
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-go-stage2-submit']
  

#                               best feature                                #
Дочекатися і Клікнути
  [Arguments]  ${locator}
  Wait Until Keyword Succeeds  15 x  1 s  Element Should Be Visible  ${locator}
  Scroll To Element  ${locator}
  Click Element  ${locator}


Wait And Select From List By Value
  [Arguments]  ${locator}  ${value}
  Wait Until Keyword Succeeds  10 x  1 s  Select From List By Value  ${locator}  ${value}

Wait And Select From List By Label
  [Arguments]  ${locator}  ${value}
  Wait Until Keyword Succeeds  10 x  1 s  Select From List By Label  ${locator}  ${value}

JQuery Ajax Should Complete
  ${active}=  Execute Javascript  return jQuery.active
  Should Be Equal  "${active}"  "0"
  

Scroll To Element
  [Arguments]  ${locator}
  ${elem_vert_pos}=  Get Vertical Position  ${locator}
  Execute Javascript  window.scrollTo(0,${elem_vert_pos - 300});


Wait Element Animation
  [Arguments]  ${locator}
  Set Test Variable  ${prev_vert_pos}  0
  Wait Until Keyword Succeeds  20 x  500 ms  Position Should Equals  ${locator}
  

Position Should Equals
  [Arguments]  ${locator}
  ${current_vert_pos}=  Get Vertical Position  ${locator}
  ${status}=  Run Keyword And Return Status  Should Be Equal  ${prev_vert_pos}  ${current_vert_pos}
  Set Test Variable  ${prev_vert_pos}  ${current_vert_pos}
  Should Be True  ${status}  
  

Накласти ЄЦП
  Run Keyword If  '${MODE}' not in "reporting negotiation belowThreshold openua openeu open_competitive_dialogue openua_defense open_esco"  Wait Until Page Contains  Накласти ЕЦП
  Capture Page Screenshot
  Sleep  5
  Run Keyword If  '${MODE}' not in "reporting negotiation belowThreshold openua openeu open_competitive_dialogue openua_defense open_esco"  Дочекатися І Клікнути  xpath=//button[contains(.,'Накласти ЕЦП')]
  Capture Page Screenshot
  Wait Until Keyword Succeeds  30 x  1 s  Page Should Contain Element  id=SignDataButton
  Wait Until Page Does Not Contain  Зчитування ключа  30
  Execute Javascript  $(".fade.modal.in").scrollTop(2000)
#новшество  Макуха Юрій
  Run Keyword If  '${MODE}' in "reporting negotiation belowThreshold openua openeu open_competitive_dialogue openua_defense open_esco"  Wait And Select From List By Label  id=CAsServersSelect  Тестовий ЦСК АТ "ІІТ"
  ${status}=  Run Keyword And Return Status  Page Should Contain  Оберіть файл з особистим ключем (зазвичай з ім'ям Key-6.dat) та вкажіть пароль захисту
  Capture Page Screenshot
  Run Keyword If  ${status}  Run Keywords
  ...  Wait And Select From List By Label  id=CAsServersSelect  Тестовий ЦСК АТ "ІІТ"
  ...  AND  Capture Page Screenshot
  ...  AND  Choose File  id=PKeyFileInput  ${CURDIR}/Key-6.dat
  ...  AND  Capture Page Screenshot
  ...  AND  Input text  id=PKeyPassword  12345677
  ...  AND  Capture Page Screenshot
  ...  AND  Дочекатися І Клікнути  id=PKeyReadButton
  ...  AND  Capture Page Screenshot
  ...  AND  Wait Until Page Contains  Користувач Укртендерс  10
  ...  AND  Capture Page Screenshot
  Дочекатися І Клікнути  id=SignDataButton
  Capture Page Screenshot


#                       ContracT                          #
#cat Редагування угоди  ${TENDER['TENDER_UAID']}  ${contract_index}  value.amount  ${amount}
Редагувати угоду
  [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${field_name}  ${amount}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  ${contract_index}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  2
  ...  ELSE IF   '${MODE}' == 'openua_defense'  Set Variable  0                   
  ...  ELSE  Set Variable  1
  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue openua_defense open_esco'  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and contains(@data-index,"${contract_index}")]
  Sleep  5
  Clear Element Text    xpath=//*[@name="contract[amount]"]
  ${budget}=  ukrtender_service.convert_float_to_string   ${amount}
  Input Text  name=contract[amount]  ${budget}
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-save']
  
Встановити дату підписання угоди
  [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${dateSigned}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  ${contract_index}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  2
  ...  ELSE IF   '${MODE}' == 'openua_defense'  Set Variable  0                   
  ...  ELSE  Set Variable  1
  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue openua_defense open_esco'  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and contains(@data-index,"${contract_index}")]
  Sleep  5
  ${dateSigned}=  ukrtender_service.convert_date_to_string_contr   ${dateSigned}
  Input Text  name=contract[signed_date]  ${dateSigned}
  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue'  Wait And Select From List By Value  xpath=//select[@id='edit-tender-dialog-contract-form-document-type']  contractSigned
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-save']
  Run Keyword If  '${MODE}' in 'open_esco'   Sleep  60


Вказати період дії угоди
  [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${startDate}  ${endDate}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  ${contract_index}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  2
  ...  ELSE IF   '${MODE}' == 'openua_defense'  Set Variable  0                   
  ...  ELSE  Set Variable  1
  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue openua_defense open_esco'  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and contains(@data-index,"${contract_index}")]
  Sleep  5
  ${startDate}=  ukrtender_service.convert_date_to_string   ${startDate}
  ${endDate}=  ukrtender_service.convert_date_to_string   ${endDate}
  Input Text  name=contract[start_date]  ${startDate}
  Input Text  name=contract[end_date]  ${endDate}
  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue openua_defense'  Wait And Select From List By Value  xpath=//select[@id='edit-tender-dialog-contract-form-document-type']  contractSigned
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-save']
  
Завантажити документ в угоду
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${contract_index}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Log Many  CAT ${document} До ЕЦПdocument
  Log Many  CAT ${contract_index}До ЕЦПqualification_num
  ${contract_index}=  Convert To Integer  ${contract_index}
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  ${contract_index}=      Run Keyword If  '${MODE}' in 'open_esco'  Set Variable  2
  ...  ELSE IF   '${MODE}' == 'openua_defense'  Set Variable  0                   
  ...  ELSE  Set Variable  1
  Run Keyword If  '${MODE}' in 'openua openeu open_competitive_dialogue openua_defense open_esco'  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and contains(@data-index,"${contract_index}")]
  Sleep  5
  ${qual_doc}=   Convert To String     Підписаний договір
  Select From List By Label  xpath=//*[@id='edit-tender-dialog-contract-form-document-type']  ${qual_doc}
  Sleep  2
  Choose File       xpath=//*[@id="edit-tender-dialog-contract-form-document"]    ${document}
  Sleep  10
  Дочекатися І Клікнути  xpath=//button[@id='edit-tender-contract-save']


#                               FUNDERS                                #
Видалити донора
  [Arguments]  ${username}  ${tender_uaid}  ${funders_index}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  name=tender[has_funder]
  Дочекатися І Клікнути               xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword And Ignore Error  Редагувати закупівлю
  
Додати донора
  [Arguments]  ${username}  ${tender_uaid}  ${funders_data}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Дочекатися І Клікнути  name=tender[has_funder]
  Дочекатися І Клікнути               xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword And Ignore Error  Редагувати закупівлю
  
Пошук тендера за кошти донора
  [Arguments]  ${username}  ${funder_id}
  Switch browser   ${username}
  Дочекатися І Клікнути  xpath=//nav[@id="site-navigation"]/descendant::a[@class="menu-tenders"]
  ${value}=  Set Variable If  '${funder_id}' == '44000'  Світовий Банк  none
  Click Element  name=funder
  Дочекатися І Клікнути            xpath=//input[@id='purchase_list_search1']
  Input Text                       xpath=//input[@id='purchase_list_search1']    ${value}
  Дочекатися І Клікнути            xpath=//input[@id='purchase-button-search-1']
  Sleep  5
  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${glo_tender_UAid}

#                               PLANS                                #
Створити план
  [Arguments]  ${username}  ${tender_data}
  ${presence}=  Run Keyword And Return Status  List Should Contain Value  ${tender_data.data}  lots
  @{lots}=  Run Keyword If  ${presence}  Get From Dictionary  ${tender_data.data}  lots
  ${presence}=  Run Keyword And Return Status  List Should Contain Value  ${tender_data.data}  items
  @{items}=  Run Keyword If  ${presence}  Get From Dictionary  ${tender_data.data}  items
  ${presence}=  Run Keyword And Return Status  List Should Contain Value  ${tender_data.data}  features
  @{features}=  Run Keyword If  ${presence}  Get From Dictionary  ${tender_data.data}  features
  Дочекатися І Клікнути  xpath=//nav[@id="site-navigation"]/descendant::a[@class="menu-plans"]
  Дочекатися І Клікнути  xpath=//a[contains(.,'Створити план')]
  Select From List By Value  xpath=//select[@name='plan[procedure_type]']  ${tender_data.data.tender.procurementMethodType}
  Input Text  xpath=//input[@name='plan[title]']  ${tender_data.data.budget.description}

  Execute Javascript    plan.changeElementValue('project_id', '${tender_data.data.budget.project.id}')
  Execute Javascript    plan.changeElementValue('project_name', "${tender_data.data.budget.project.name}")
  Execute Javascript    plan.changeElementValue('budget_id', '${tender_data.data.budget.id}')
  Execute Javascript    plan.changeElementValue('procuringentity_identifier_id', '${tender_data.data.procuringEntity.identifier.id}')
  Execute Javascript    plan.changeElementValue('procuringentity_identifier_legal_name', "${tender_data.data.procuringEntity.identifier.legalName}")
  Execute Javascript    plan.changeElementValue('procuringentity_name', "${tender_data.data.procuringEntity.name}")
  Execute Javascript    plan.changeElementValue('procuringentity_identifier_scheme', "${tender_data.data.procuringEntity.identifier.scheme}")
  
#cat  Execute Javascript    plan.changeElementValue('procuringentity_scheme', "${tender_data.data.procuringEntity.scheme}")
  
  ${amount}=  ukrtender_service.convert_float_to_string  ${tender_data.data.budget.amount}
  Input Text  xpath=//input[@name='plan[amount]']  ${amount}

  ${startdate}=  ukrtender_service.convert_date_to_string  ${tender_data.data.tender.tenderPeriod.startDate}
  Input Text  xpath=//input[@name='plan[start_date]']  ${startdate}

  Wait Until Element Is Visible       xpath=//input[@name='plan[dk_021_2015][title]']   90
  Input text                          xpath=//input[@name='plan[dk_021_2015][title]']    ${tender_data.data.classification.description}
  Дочекатися І Клікнути  xpath=//input[@name='plan[dk_021_2015][title]']
  ${class}=  conc_class  ${tender_data.data.classification.description}  ${tender_data.data.classification.id}
  Log Many  CAT888 ${class}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//div[contains(text(),'${class}')]
  ${present_class}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${class}')]
  Run Keyword If    ${present_class}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${class}')]

  ${dk_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${tender_data.data}    additionalClassifications
  ${is_CPV_other}=  Run Keyword And Return Status  Should Be Equal  '${tender_data.data.classification.id}'  '99999999-9'
  ${is_MOZ}=  Run Keyword And Return Status  Should Be Equal  '${tender_data.data.additionalClassifications[0].scheme}'  'INN'
  Run Keyword If  '${tender_data.data.additionalClassifications[0].scheme}' != 'ДКПП' or ${is_MOZ}  Вибрати додатковий класифікатор плану  ${tender_data}  -1  ${is_MOZ}

#cat block item
  Дочекатися І Клікнути  xpath=//input[@value='+ Додати товар або послугу']
  Wait Until Element Is Visible       xpath=//input[@name='plan[items][0][dk_021_2015][title]']   90
  Input text                          xpath=//input[@name='plan[items][0][dk_021_2015][title]']    ${items[0].classification.description}
  Дочекатися І Клікнути  xpath=//input[@name='plan[items][0][dk_021_2015][title]']
  ${class1}=  conc_class  ${items[0].classification.description}  ${items[0].classification.id}
  Log Many  CAT888 ${class}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//div[contains(text(),'${class1}') and (@data-index='0')]
  ${present_class1}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${class1}') and (@tabindex="-1")]
  Run Keyword If    ${present_class1}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${class1}') and (@tabindex="-1")]

  ${dk_status1}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${tender_data.data.items[0]}    additionalClassifications
  ${is_CPV_other1}=  Run Keyword And Return Status  Should Be Equal  '${items[0].classification.id}'  '99999999-9'
  ${is_MOZ1}=  Run Keyword And Return Status  Should Be Equal  '${items[0].additionalClassifications[0].scheme}'  'INN'
  Run Keyword If  '${items[0].additionalClassifications[0].scheme}' != 'ДКПП' or ${is_MOZ1}  Вибрати додатковий класифікатор предмету плану  ${items}  0  ${is_MOZ1}

  Input Text  xpath=//input[@name='plan[items][0][name]']  ${items[0].description}
  ${item_quantity}=        convert_float_to_string_3f  ${items[0].quantity}
  Input Text  xpath=//input[contains(@name,'plan[items][0][quantity]')]  ${item_quantity}
  Select From List By Label  xpath=//select[@name='plan[items][0][unit]']  ${items[0].unit.name}
  ${enddate}=  ukrtender_service.convert_date_to_string  ${items[0].deliveryDate.endDate}
  Input Text  xpath=//input[@name='plan[items][0][delivery_end_date]']  ${enddate}

#cat block item1
  Дочекатися І Клікнути  xpath=//input[@value='+ Додати товар або послугу']
  Wait Until Element Is Visible       xpath=//input[@name='plan[items][1][dk_021_2015][title]']   90
  Input text                          xpath=//input[@name='plan[items][1][dk_021_2015][title]']    ${items[1].classification.description}
  Дочекатися І Клікнути  xpath=//input[@name='plan[items][1][dk_021_2015][title]']
  ${class1}=  conc_class  ${items[1].classification.description}  ${items[1].classification.id}
  Log Many  CAT888 ${class}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//div[contains(text(),'${class1}') and (@data-index='1')]
  ${present_class1}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${class1}') and (@data-index='1')]
  Run Keyword If    ${present_class1}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${class1}') and (@tabindex="-1")]

  ${dk_status1}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${tender_data.data.items[1]}    additionalClassifications
  ${is_CPV_other1}=  Run Keyword And Return Status  Should Be Equal  '${items[1].classification.id}'  '99999999-9'
  ${is_MOZ1}=  Run Keyword And Return Status  Should Be Equal  '${items[1].additionalClassifications[0].scheme}'  'INN'
  Run Keyword If  '${items[1].additionalClassifications[0].scheme}' != 'ДКПП' or ${is_MOZ1}  Вибрати додатковий класифікатор предмету плану  ${items}  1  ${is_MOZ1}

  Input Text  xpath=//input[@name='plan[items][1][name]']  ${items[1].description}
  ${item_quantity1}=        convert_float_to_string_3f  ${items[1].quantity}
  Input Text  xpath=//input[contains(@name,'plan[items][1][quantity]')]  ${item_quantity1}
  Select From List By Label  xpath=//select[@name='plan[items][1][unit]']  ${items[1].unit.name}
  Select From List By Label  xpath=//select[@name='plan[items][1][unit]']  ${items[1].unit.name}
  ${enddate}=  ukrtender_service.convert_date_to_string  ${items[1].deliveryDate.endDate}
  Input Text  xpath=//input[@name='plan[items][1][delivery_end_date]']  ${enddate}

  Дочекатися І Клікнути  xpath=//input[@value='Опублікувати план']
  Sleep  18
  ${plan_id}  Get Value  xpath=//input[@name='plan[planID]']
  [Return]  ${plan_id}
  
Вибрати додатковий класифікатор плану
  [Arguments]  ${tender_data}  ${index}  ${is_MOZ}
  ${status}=  Set Variable If  '${index}' == 'null'  'false'  'true'
#cat block plan
  Run Keyword If  ${index} == -1 and '${tender_data.data.additionalClassifications[0].scheme}' == 'ДК018'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 018-2000')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_018_2000][title]']   ${tender_data.data.additionalClassifications[0].description}
  ...  AND  ${present2}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present2}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If   ${index} == -1 and '${tender_data.data.additionalClassifications[0].scheme}' == 'ДК003'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 003-2010')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_003_2010][title]']   ${tender_data.data.additionalClassifications[0].description}
  ...  AND  ${present3}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present3}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If  ${index} == -1 and '${tender_data.data.additionalClassifications[0].scheme}' == 'spec'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'Спеціальні норми та інше')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_special][title]']   ${tender_data.data.additionalClassifications[0].description}
  ...  AND  ${present4}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present4}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
#cat#cat  INN
  Run Keyword If  ${index} == -1 and '${tender_data.data.additionalClassifications[0].scheme}' == 'INN'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[@href='#edit-plan-dialog-add-classificator-tab-5']
  ...  AND  Clear Element Text    xpath=//input[@id='edit-plan-dialog-add-classificator-mozmnn-title']
  ...  AND  Input Text  xpath=//input[@id='edit-plan-dialog-add-classificator-mozmnn-title']   ${tender_data.data.additionalClassifications[0].description}
  Sleep  4
  Log Many  CAT888 ${tender_data.data.additionalClassifications[0].description}
  ${present_inn}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${tender_data.data.additionalClassifications[0].description}')]
  Run Keyword If    ${present_inn}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${tender_data.data.additionalClassifications[0].description}')]
#cat#cat  ATX
  Log Many  CAT888 ${tender_data.data.additionalClassifications[1].description}
  ${con_class}=  Run Keyword If  ${index} == -1 and '${tender_data.data.additionalClassifications[1].scheme}' == 'ATC'   conc_class  ${tender_data.data.additionalClassifications[1].description}  ${tender_data.data.additionalClassifications[1].id}
  Log Many  CAT888 ${con_class}
  Run Keyword If  ${index} == -1 and '${tender_data.data.additionalClassifications[1].scheme}' == 'ATC'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[@href='#edit-plan-dialog-add-classificator-tab-6']
  ...  AND  Clear Element Text    xpath=//input[@id='edit-plan-dialog-add-mozatx-title']
  ...  AND  Input Text  xpath=//input[@id='edit-plan-dialog-add-mozatx-title']   ${tender_data.data.additionalClassifications[1].description}
  Sleep  4
  ${present_atx}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${con_class}')]
  Run Keyword If    ${present_atx}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${con_class}')]

  Sleep  2
  Дочекатися І Клікнути  xpath=//button[@id='edit-plan-add-classificator-submit']

Вибрати додатковий класифікатор предмету плану
  [Arguments]  ${items}  ${index}  ${is_MOZ}

#cat block item
  Run Keyword If  '${items[${index}].additionalClassifications[0].scheme}' == 'ДК018'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 018-2000')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_018_2000][title]']   ${items[${index}].additionalClassifications[0].description}
  ...  AND  ${present2}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present2}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If  '${items[${index}].additionalClassifications[0].scheme}' == 'ДК003'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 003-2010')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_003_2010][title]']   ${items[${index}].additionalClassifications[0].description}
  ...  AND  ${present3}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present3}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If  '${items[${index}].additionalClassifications[0].scheme}' == 'spec'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'Спеціальні норми та інше')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_special][title]']   ${items[${index}].additionalClassifications[0].description}
  ...  AND  ${present4}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present4}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
#cat#cat  INN
  Run Keyword If  '${items[${index}].additionalClassifications[0].scheme}' == 'INN'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[@href='#edit-plan-dialog-add-classificator-item-tab-5']
  ...  AND  Clear Element Text    xpath=//input[@id='edit-plan-dialog-add-classificator-item-mozmnn-title']
  ...  AND  Input Text  xpath=//input[@id='edit-plan-dialog-add-classificator-item-mozmnn-title']   ${items[${index}].additionalClassifications[0].description}
  Sleep  4
  ${con_class1}=  Run Keyword If  '${items[${index}].additionalClassifications[0].scheme}' == 'INN'   conc_class  ${items[${index}].additionalClassifications[0].description}  ${items[${index}].additionalClassifications[0].id}

  ${present_inn}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${con_class1}') and (@data-item-additional='${index}')]
  Run Keyword If    ${present_inn}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${con_class1}') and (@data-item-additional='${index}')]
#cat#cat  ATX
  ${con_class}=  Run Keyword If  '${items[${index}].additionalClassifications[1].scheme}' == 'ATC'   conc_class  ${items[${index}].additionalClassifications[1].description}  ${items[${index}].additionalClassifications[1].id}
  Log Many  CAT888 ${con_class}
  Run Keyword If  '${items[${index}].additionalClassifications[1].scheme}' == 'ATC'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[@href='#edit-plan-dialog-add-classificator-item-tab-6']
  ...  AND  Clear Element Text    xpath=//input[@id='edit-plan-dialog-add-classificator-item-mozatx-title']
  ...  AND  Input Text  xpath=//input[@id='edit-plan-dialog-add-classificator-item-mozatx-title']   ${items[${index}].additionalClassifications[1].description}
  Sleep  4
  ${present_atx}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${con_class}') and (@data-item-additional='${index}')]
  Run Keyword If    ${present_atx}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${con_class}') and (@data-item-additional='${index}')]

  Sleep  2
  Дочекатися І Клікнути  xpath=//button[@id='edit-plan-add-classificator-item-submit']
  
Вибрати додатковий класифікатор предмету плану2
  [Arguments]  ${item}  ${index}  ${is_MOZ}

#cat block item
  Run Keyword If  '${item.additionalClassifications[0].scheme}' == 'ДК018'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 018-2000')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_018_2000][title]']   ${item.additionalClassifications[0].description}
  ...  AND  ${present2}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present2}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If  '${item.additionalClassifications[0].scheme}' == 'ДК003'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'ДК 003-2010')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_003_2010][title]']   ${item.additionalClassifications[0].description}
  ...  AND  ${present3}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present3}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  Run Keyword If  '${item.additionalClassifications[0].scheme}' == 'spec'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[contains(.,'Спеціальні норми та інше')]
  ...  AND  Input Text  xpath=//input[@name='add_classificator[dk_special][title]']   ${item.additionalClassifications[0].description}
  ...  AND  ${present4}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
  ...  AND  Run Keyword If    ${present4}    Дочекатися І Клікнути                       xpath=//div[contains(@class,'ui-menu-item-wrapper ui-state-active')]
#cat#cat  INN
  Run Keyword If  '${item.additionalClassifications[0].scheme}' == 'INN'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[@href='#edit-plan-dialog-add-classificator-item-tab-5']
  ...  AND  Clear Element Text    xpath=//input[@id='edit-plan-dialog-add-classificator-item-mozmnn-title']
  ...  AND  Input Text  xpath=//input[@id='edit-plan-dialog-add-classificator-item-mozmnn-title']   ${item.additionalClassifications[0].description}
  Sleep  4
  ${con_class1}=  Run Keyword If  '${item.additionalClassifications[0].scheme}' == 'INN'   conc_class  ${item.additionalClassifications[0].description}  ${item.additionalClassifications[0].id}

  ${present_inn}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${con_class1}') and (@data-item-additional='${index}')]
  Run Keyword If    ${present_inn}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${con_class1}') and (@data-item-additional='${index}')]
#cat#cat  ATX
  ${con_class}=  Run Keyword If  '${item.additionalClassifications[1].scheme}' == 'ATC'   conc_class  ${item.additionalClassifications[1].description}  ${item.additionalClassifications[1].id}
  Log Many  CAT888 ${con_class}
  Run Keyword If  '${item.additionalClassifications[1].scheme}' == 'ATC'   Run Keywords
  ...  Дочекатися І Клікнути  xpath=//a[@href='#edit-plan-dialog-add-classificator-item-tab-6']
  ...  AND  Clear Element Text    xpath=//input[@id='edit-plan-dialog-add-classificator-item-mozatx-title']
  ...  AND  Input Text  xpath=//input[@id='edit-plan-dialog-add-classificator-item-mozatx-title']   ${item.additionalClassifications[1].description}
  Sleep  4
  ${present_atx}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[contains(text(),'${con_class}') and (@data-item-additional='${index}')]
  Run Keyword If    ${present_atx}    Дочекатися І Клікнути                       xpath=//div[contains(text(),'${con_class}') and (@data-item-additional='${index}')]

  Sleep  2
  Дочекатися І Клікнути  xpath=//button[@id='edit-plan-add-classificator-item-submit']

Оновити сторінку з планом
  [Arguments]  ${username}  ${tenderId}
  Reload Page
  Sleep  2

Пошук плану по ідентифікатору
  [Arguments]  ${username}  ${tenderId}
  Switch browser   ${username}
  Go to   ${USERS.users['${username}'].homepage}
  
  Log Many  CAT888 ${username}
  Дочекатися І Клікнути  xpath=//nav[@id="site-navigation"]/descendant::a[@class="menu-plans"]
  Run Keyword If    '${username}' == 'ukrtender_Owner'  Click Element            xpath=//span[contains(.,'Всі плани Prozorro')]
  Click Element            xpath=//input[@id='filter-keyword-3']
  Input Text               xpath=//input[@id='filter-keyword-3']    ${tenderId}

  Wait Until Keyword Succeeds  20x  20s  Run Keywords
  ...  Click Element  xpath=//input[contains(@data-tab,'3')]
  ...  AND  Wait Until Element Is Visible  xpath=//a[contains(@id,'plan-list-3-procuring-link-0') and contains(@data-planid,'${tenderId}')]  10
#cat  ...  AND  Wait Until Element Is Visible  xpath=//a[contains(@id,'plan-list--procuring-link-0') and contains(@data-planid,'${tenderId}')]  10

  Click Element    xpath=//a[contains(@id,'plan-list-3-procuring-link-0') and contains(@data-planid,'${tenderId}')]

Додати предмети закупівлі в план
    [Arguments]  ${items}
    ${items_count}=  Get Length  ${items}

    : FOR  ${index}  IN RANGE  0  ${items_count}
    \  ${index_xpath}=  privatmarket_service.sum_of_numbers  ${index}  1
    \  Run Keyword If  ${index} > 0  Click Element  xpath=//button[@data-id='actAddItem']
    \  Wait Element Visibility And Input Text  xpath=(//input[@data-id='description'])[${index_xpath}]  ${items[${index}].description}
    \  ${item_quantity}=        convert_float_to_string_3f  ${items[index].quantity}
#cat    \  Input Text  xpath=(//input[@data-id='quantity'])[${index_xpath}]  ${items[${index}].quantity}
    \  Input Text  xpath=(//input[@data-id='quantity'])[${index_xpath}]  ${item_quantity}
    \  Select From List By Label  xpath=(//select[@data-id='unit'])[${index_xpath}]  ${items[${index}].unit.name}
    \  Set Date In Item  ${index}  deliveryDate  endDate  ${items[${index}].deliveryDate.endDate}
    Дочекатися І Клікнути  xpath=//input[@value='Редагувати план']


Внести зміни в план
  [Arguments]  ${user_name}  ${tenderId}  ${parameter}  ${value}
  ukrtender.Пошук плану по ідентифікатору  ${tender_owner}  ${tenderId}

  Run Keyword If  '${parameter}' == 'budget.description'  Input Text  xpath=//input[@name='plan[title]']  ${value}

  ${amount}=  Run Keyword If  '${parameter}' == 'budget.amount'  convert_float_to_string  ${value}
  Run Keyword If  '${parameter}' == 'budget.amount'  Input Text  xpath=//input[@name='plan[amount]']  ${amount}

  Run Keyword If  '${parameter}' == 'items[0].quantity'  Clear Element Text  xpath=//input[contains(@name,'plan[items][0][quantity]')]
  ${item_quantity}=    Run Keyword If  '${parameter}' == 'items[0].quantity'      convert_float_to_string  ${value}
  Run Keyword If  '${parameter}' == 'items[0].quantity'  Input Text  xpath=//input[contains(@name,'plan[items][0][quantity]')]  ${item_quantity}
#cat  Run Keyword If  '${parameter}' == 'items[0].quantity'  Input Text  xpath=//input[contains(@name,'plan[items][0][quantity]')]  ${value}
  ${enddate}=  Run Keyword If  '${parameter}' == 'items[0].deliveryDate.endDate'  ukrtender_service.convert_date_to_string  ${value}
  Run Keyword If  '${parameter}' == 'items[0].deliveryDate.endDate'  Clear Element Text  xpath=//input[@name='plan[items][0][delivery_end_date]']
  Run Keyword If  '${parameter}' == 'items[0].deliveryDate.endDate'  Input Text  xpath=//input[@name='plan[items][0][delivery_end_date]']  ${enddate}

  Дочекатися І Клікнути  xpath=//input[@value='Редагувати план']


Додати предмет закупівлі в план
  [Arguments]  ${tender_owner}  ${tender_uaid}  ${item}
  ukrtender.Пошук плану по ідентифікатору  ${tender_owner}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//input[@value='+ Додати товар або послугу']
  Wait Until Element Is Visible       xpath=//input[@name='plan[items][2][dk_021_2015][title]']   90
  Input text                          xpath=//input[@name='plan[items][2][dk_021_2015][title]']    ${item.classification.description}
  Дочекатися І Клікнути  xpath=//input[@name='plan[items][2][dk_021_2015][title]']
  ${class1}=  conc_class  ${item.classification.description}  ${item.classification.id}
  Sleep  2
  Дочекатися І Клікнути                       xpath=//div[contains(text(),'${class1}') and (@data-index='2')]

  ${dk_status1}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${tender_data.data.item}    additionalClassifications
  ${is_CPV_other1}=  Run Keyword And Return Status  Should Be Equal  '${item.classification.id}'  '99999999-9'
  ${is_MOZ1}=  Run Keyword And Return Status  Should Be Equal  '${item.additionalClassifications.scheme}'  'INN'
  Run Keyword If  '${item.additionalClassifications[0].scheme}' != 'ДКПП' or ${is_MOZ1}  Вибрати додатковий класифікатор предмету плану2  ${item}  2  ${is_MOZ1}

  Input Text  xpath=//input[@name='plan[items][2][name]']  ${item.description}
  ${item_quantity}=        convert_float_to_string_3f  ${item.quantity}
  Input Text  xpath=//input[contains(@name,'plan[items][2][quantity]')]  ${item_quantity}
  Select From List By Label  xpath=//select[@name='plan[items][2][unit]']  ${item.unit.name}

  Дочекатися І Клікнути  xpath=//input[@value='Редагувати план']


Видалити предмет закупівлі плану
  [Arguments]  ${tender_owner}  ${tender_uaid}  ${item}
  ukrtender.Пошук плану по ідентифікатору  ${tender_owner}  ${tender_uaid}
  Дочекатися І Клікнути  xpath=//input[@value='Видалити товар або послугу' and contains(@data-index,'1')]
  Дочекатися І Клікнути  xpath=//input[@value='Редагувати план']


Отримати інформацію із плану
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}
  Log Many  CAT888 ${field_name}
  ${value}=  Run Keyword If  '${field_name}' == 'tender.procurementMethodType'  Get Value  xpath=//input[@name='plan[procedure_type]']
  ...  ELSE IF  '${field_name}' == 'budget.amount'  Get Value  xpath=//input[@name='plan[amount]']
  ...  ELSE IF  '${field_name}' == 'budget.currency'  Get Value  xpath=//input[@name='plan[currency]']
  ...  ELSE IF  '${field_name}' == 'budget.description'  Get Value  xpath=//input[@name='plan[title]']
  ...  ELSE IF  '${field_name}' == 'budget.id'  Get Value  xpath=//input[@name='plan[budget_id]']
  ...  ELSE IF  '${field_name}' == 'budget.project.id'  Get Value  xpath=//input[@name='plan[project_id]']
  ...  ELSE IF  '${field_name}' == 'budget.project.name'  Get Value  xpath=//input[@name='plan[project_name]']
  ...  ELSE IF  '${field_name}' == 'procuringEntity.name'  Get Value  xpath=//input[@name='plan[procuringentity_name]']
  ...  ELSE IF  '${field_name}' == 'procuringEntity.identifier.legalName'  Get Value  xpath=//input[@name='plan[procuringentity_identifier_legal_name]']
  ...  ELSE IF  '${field_name}' == 'procuringEntity.identifier.id'  Get Value  xpath=//input[@name='plan[procuringentity_identifier_id]']
  ...  ELSE IF  '${field_name}' == 'procuringEntity.identifier.scheme'  Get Value  xpath=//input[@name='plan[procuringentity_identifier_scheme]']
  ...  ELSE IF  '${field_name}' == 'classification.description'  Get Value  xpath=//input[@name='plan[dk_021_2015][short_title]']
  ...  ELSE IF  '${field_name}' == 'classification.scheme'  Get Value  xpath=//input[@name='plan[dk_021_2015][scheme]']
  ...  ELSE IF  '${field_name}' == 'classification.id'  Get Value  xpath=//input[@name='plan[dk_021_2015][id]']
  ...  ELSE IF  '${field_name}' == 'tender.tenderPeriod.startDate'  Get Value  xpath=//input[@name='plan[start_date]']
  ...  ELSE IF  '${field_name}' == 'items[0].description'  Get Value  xpath=//input[@name='plan[items][0][name]']
  ...  ELSE IF  '${field_name}' == 'items[0].quantity'  Get Value  xpath=//input[@name='plan[items][0][quantity]']
  ...  ELSE IF  '${field_name}' == 'items[0].deliveryDate.endDate'  Get Value  xpath=//input[@name='plan[items][0][delivery_end_date]']
  ...  ELSE IF  '${field_name}' == 'items[0].unit.code'  Get Value  xpath=//input[@name='plan[items][0][unit]']
  ...  ELSE IF  '${field_name}' == 'items[0].unit.name'  Get Value  xpath=//input[@name='plan[items][0][unit_name]']
  ...  ELSE IF  '${field_name}' == 'items[0].classification.description'  Get Value  xpath=//input[@name='plan[items][0][dk_021_2015][short_title]']
  ...  ELSE IF  '${field_name}' == 'items[0].classification.scheme'  Get Value  xpath=//input[@name='plan[items][0][dk_021_2015][scheme]']
  ...  ELSE IF  '${field_name}' == 'items[0].classification.id'  Get Value  xpath=//input[@name='plan[items][0][dk_021_2015][id]']
  ...  ELSE IF  '${field_name}' == 'items[1].description'  Get Value  xpath=//input[@name='plan[items][1][name]']
  ...  ELSE IF  '${field_name}' == 'items[1].quantity'  Get Value  xpath=//input[@name='plan[items][1][quantity]']
  ...  ELSE IF  '${field_name}' == 'items[1].deliveryDate.endDate'  Get Value  xpath=//input[@name='plan[items][1][delivery_end_date]']
  ...  ELSE IF  '${field_name}' == 'items[1].unit.code'  Get Value  xpath=//input[@name='plan[items][1][unit]']
  ...  ELSE IF  '${field_name}' == 'items[1].unit.name'  Get Value  xpath=//input[@name='plan[items][1][unit_name]']
  ...  ELSE IF  '${field_name}' == 'items[1].classification.description'  Get Value  xpath=//input[@name='plan[items][1][dk_021_2015][short_title]']
  ...  ELSE IF  '${field_name}' == 'items[1].classification.scheme'  Get Value  xpath=//input[@name='plan[items][1][dk_021_2015][scheme]']
  ...  ELSE IF  '${field_name}' == 'items[1].classification.id'  Get Value  xpath=//input[@name='plan[items][1][dk_021_2015][id]']

  ${value}=  Run Keyword If  '${field_name}' == 'budget.amount'  convert_string_to_float  ${value}
  ...  ELSE IF  '${field_name}' == 'tender.tenderPeriod.startDate'  ukrtender_service.convert_time  ${value}
  ...  ELSE IF  '${field_name}' == 'items[0].quantity'  convert_string_to_float  ${value}
  ...  ELSE IF  '${field_name}' == 'items[1].quantity'  convert_string_to_float  ${value}
  ...  ELSE  Set Variable  ${value}
  ${value}=  Run Keyword If  '${field_name}' == 'tender.tenderPeriod.startDate'  ukrtender_service.data_zone  ${value}
  ...  ELSE  Set Variable  ${value}
  [Return]  ${value}

# ESCO   #  
Отримати індекс елементу поля зі статусом
  [Arguments]  ${username}  ${tender_uaid}  ${field_name}  ${status}
  Go To  http://test.ukrtender.com.ua/tender-detail/?id=${tender_uaid}
#cat  ukrtender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${value}=  Run Keyword If  '${field_name}' == 'awards'  Get Element Attribute  xpath=//*[contains(@award-status,'active')]@award-index
  ...  ELSE IF  '${field_name}' == 'contract' and '${status}' == 'pending'  Get Element Attribute  xpath=//*[contains(@contract-status,'pending')]@contract-index
  ...  ELSE IF  '${field_name}' == 'contract' and '${status}' == 'active'  Get Element Attribute  xpath=//*[contains(@contract-status,'active')]@contract-index
  [Return]  ${value}

Редагувати закупівлю
  Run Keyword And Ignore Error  Wait Until Element Is Visible  xpath=//button[@id='edit-tender-information-dialog-submit']  5
  Run Keyword And Ignore Error  Click Element   xpath=//button[@id='edit-tender-information-dialog-submit']
  Run Keyword And Ignore Error  Wait Until Element Is Visible  xpath=//button[@id='edit-tender-confirm-dialog-submit']  5
  Run Keyword And Ignore Error  Click Element   xpath=//button[@id='edit-tender-confirm-dialog-submit']
#cat  Run Keyword And Ignore Error  Wait Until Element Is Visible  xpath=//*[text()="Редагувати закупівлю"]  5
#cat  Run Keyword And Ignore Error  Click Element   xpath=//*[text()="Редагувати закупівлю"]
  Run Keyword And Ignore Error  Wait Until Element Is Visible  xpath=//button[@id='edit-tender-information-dialog-submit']  5
  Run Keyword And Ignore Error  Click Element   xpath=//button[@id='edit-tender-information-dialog-submit']