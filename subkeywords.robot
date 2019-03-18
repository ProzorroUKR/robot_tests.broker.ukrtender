*** Settings ***

Library  Selenium2Library
Library  String
Library  DateTime
Library  Collections
Library  ukrtender_service.py
Library  get_xpath.py


*** Keywords ***

Змінити дату
  [Arguments]  ${fieldvalue}
  Clear Element Text    xpath=//*[@name="tender[reception_to]"]
  ${endDate}=           ukrtender_service.convert_date_to_string_contr    ${fieldvalue}
#cat  ${endDate}=           ukrtender_service.convert_date_to_string    ${fieldvalue}
  Input Text            xpath=//*[@name="tender[reception_to]"]    ${endDate}

Змінити опис
  [Arguments]  ${fieldvalue}
  Clear Element Text    xpath=//*[@name="tender[description]"]
  Input Text            xpath=//*[@name="tender[description]"]    ${fieldvalue}

Отримати дані з поля item
  [Arguments]  ${field}  ${item_id}
  Log Many  CAT777 ${item_id}
  ${index_item}=   Execute Javascript    return $( 'input[value*="${item_id}"]' ).attr( 'name' )
  Log Many  CAT777 ${index_item}
  ${item_index}=  split_str  ${index_item}
  ${field_xpath}=    get_xpath.get_item_xpath    ${field}    ${item_id}  ${item_index}
  Log Many  CAT888 ${field_xpath}
  ${type_field}=    get_type_field    ${field}
  ${value} =  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
    ...     ELSE IF             '${type_field}' == 'text'    Get Text    ${field_xpath}

  [return]  ${value}

Адаптувати дані з поля item
  [Arguments]  ${field}  ${value}
  ${value}=  Run Keyword If    '${field}' == 'unit.name'    ukrtender_service.get_unit    ${field}    ${value}
    ...      ELSE IF           '${field}' == 'unit.code'    ukrtender_service.get_unit    ${field}    ${value}
    ...      ELSE IF           '${field}' == 'quantity'     Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryLocation.latitude'    Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryLocation.longitude'    Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryDate.startDate'    ukrtender_service.parse_date    ${value}
    ...      ELSE IF           '${field}' == 'deliveryDate.endDate'    ukrtender_service.parse_date    ${value}
    ...      ELSE               Set Variable    ${value}
  [return]  ${value}

Отримати дані з поля lot
  [Arguments]  ${field}  ${lot_id}
  ${index_lot}=   Execute Javascript    return $( 'input[value*="${lot_id}"]' ).attr( 'name' )
  Log Many  CAT777 ${index_lot}
  ${lot_index}=  split_str  ${index_lot}
  ${field_xpath}=    get_xpath.get_lot_xpath    ${field}    ${lot_id}    ${lot_index}
  ${type_field}=    ukrtender_service.get_type_field    ${field}
  ${value}=  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
  ...        ELSE IF           '${type_field}' == 'text'    Get Text    ${field_xpath}
  Log Many  CAT999 Отримати дані ${field} з поля lot ${value}
  [return]  ${value}

Адаптувати дані з поля lot
  [Arguments]  ${field}  ${value}
  ${value}=  Run Keyword If    '${field}' == 'value.amount'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'minimalStep.amount'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'value.currency'    ukrtender_service.convert_data_lot    ${value}
  ...        ELSE IF           '${field}' == 'minimalStep.currency'    ukrtender_service.convert_data_lot    ${value}
  ...        ELSE IF           '${field}' == 'value.valueAddedTaxIncluded'    Convert To Boolean    True
  ...        ELSE IF           '${field}' == 'minimalStep.valueAddedTaxIncluded'    Convert To Boolean    True
  ...        ELSE              Set Variable    ${value}
  [return]  ${value}

Отримати дані з поля feature
  [Arguments]  ${field_name}  ${feature_id}
  Log Many  CAT888 ${field_name}
  Log Many  CAT777 ${feature_id}
  ${field_xpath}=    ukrtender_service.get_feature_xpath    ${field_name}  ${feature_id}
  ${type_field}=    ukrtender_service.get_type_field    ${field_name}
  Wait Until Keyword Succeeds  5 x  10 s  Run Keywords
  ...  Reload Page
  ...  AND  Wait Until Page Contains Element  xpath=//input[contains(@value,"${feature_id}")]
  ${value}=  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
  ...        ELSE IF           '${type_field}' == 'text'    Get Text    ${field_xpath}
  [return]  ${value}

Get Scheme
  [Arguments]  ${value}
  ${value}=    Get Substring    ${value}    36    42
  ${value}=    Replace String    ${value}    ${space}    ${empty}
  [return]  ${value}

Wait For Question
  [Arguments]  ${field_xpath}
  Wait Until Keyword Succeeds  6x  10s  Run Keywords
  ...  Reload page
  ...  AND  Sleep  1
  ...  AND  Scroll To Element       xpath=//span[contains(.,'Питання та відповіді')]
  ...  AND  Дочекатися І Клікнути  xpath=//span[contains(.,'Питання та відповіді')]
  ...  AND  Wait Until Element Is Visible  xpath=${field_xpath}  10

Wait For TenderPeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//input[@value='active.tendering']

Wait For AuctionPeriod
  Reload Page
  Sleep  3
  Log Many  CATAuctionPeriod ${return_value}
  Page Should Contain Element    xpath=//input[@value='active.auction']

Wait For PreQualificationPeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//input[@value='active.pre-qualification']

Wait For PreQualificationsStandPeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//input[@value='active.pre-qualification.stand-still']

Wait For CompletePeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//input[@value='complete']
  
Wait For ActiveStage2Pending
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//input[@value='active.stage2.pending']
  
Wait For ActiveStage2Waiting
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//input[@value='active.stage2.waiting']
  
Wait For NewLot
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//input[@name='tender[lots][1][name]']

Wait For NewItem
  [Arguments]  ${item_id}
  Reload Page
  Sleep  3
  Execute JavaScript                  window.scrollTo(0, 1000)
  Sleep  2
  Click Element    xpath=//*[text()="Додати позицію"]
  Sleep  2
  Page Should Contain Element    xpath=//*[contains(text(), '${item_id}')]

Wait For NewFeature
  [Arguments]  ${feature_id}
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[contains(@value, '${feature_id}')]

Wait For Document
  [Arguments]  ${field_xpath}
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=${field_xpath}

Wait For NotTenderPeriod
  Reload Page
  Sleep  3
  Wait Until Page Does Not Contain Element  xpath=//input[@value='active.tendering']

Wait For QualificationsStandPeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[contains(@value, 'active.qualification')]

Wait For ButtonComplaint
  Reload Page
  Sleep  3
  Execute JavaScript                  window.scrollTo(0, 0)
  Дочекатися І Клікнути    xpath=//span[contains(.,'Вимоги')]
  Wait Until Element Is Visible    xpath=//a[@id='tender-complaint-edit-button-popup']

Wait For EscoButtonContract
  Reload Page
  Sleep  3
  Execute JavaScript                  window.scrollTo(0, 0)
  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  Wait Until Element Is Visible    xpath=//a[@id='edit-tender-award-item-go-button-3']

Wait For ClaimTender
  [Arguments]  ${complaint_index}
  Reload Page
  Sleep  3
  Execute JavaScript                  window.scrollTo(0, 0)
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Page Should Contain Element    xpath=//h3[@id='tender-complaint-list-title-${complaint_index}']

Wait For ClaimLot
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[2]

Wait For ComplaintID
  [Arguments]  ${complaintID}
  Reload Page
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  5
  Page Should Contain Element    xpath=//input[contains(@value,"${complaintID}")]

Wait For Answered
  [Arguments]  ${complaint_index}
  Reload Page
  Execute JavaScript                  window.scrollTo(0, 0)
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Page Should Contain Element    xpath=//input[@id='tender-complaint-list-status-${complaint_index}' and @value="answered"]

Wait For Satisfied
  [Arguments]  ${complaint_index}
  Reload Page
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  5
  Page Should Contain Element    xpath=//input[@id='tender-complaint-list-satisfied-${complaint_index}' and @value="1"]

Wait For Cancelled
  [Arguments]  ${complaint_index}
  Reload Page
  Execute Javascript    tenderInformation.refreshTender()
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  5
  Page Should Contain Element    xpath=//input[@id='tender-complaint-list-status-${complaint_index}' and @value="cancelled"]

Wait For Stopping
  [Arguments]  ${complaint_index}
  Reload Page
  Execute Javascript    tenderInformation.refreshTender()
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  5
  Page Should Contain Element    xpath=//input[@id='tender-complaint-list-status-${complaint_index}' and @value="stopping"]

Wait For EndEnquire
  Reload Page
  Sleep  3
  ${return_value}=  Get Value  xpath=//*[@name='tender[status]']
  Log Many  CAT111 ${return_value}
  Page Should Not Contain Element    xpath=//*[@value='active.tendering']

Wait For Ignored
  [Arguments]  ${complaint_index}
  Reload Page
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  5
  Page Should Contain Element    xpath=//input[@id='tender-complaint-list-status-${complaint_index}' and @value="ignored"]

Wait For ContractButton
  [Arguments]  ${contract_num}
  Reload Page
  Execute Javascript    tenderInformation.refreshTender()
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Sleep  5
  Wait Until Element Is Visible    xpath=//a[contains(.,'Підписати контракт') and contains(@data-index,"${contract_num}")]
  
Wait For PrequalificationButton2
  Reload Page
  Execute Javascript    tenderInformation.refreshTender()
  Sleep  3
  Wait Until Element Is Visible    xpath=//*[@id='edit-tender-prequalification-qualification-go-button-2']
  
Wait For AwardButton2
  Reload Page
  Execute Javascript    tenderInformation.refreshTender()
  Sleep  3
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Sleep  5
  Wait Until Element Is Visible    xpath=//a[@id='edit-tender-award-item-go-button-2']
  
Wait For AwardButton1
  Reload Page
  Execute Javascript    tenderInformation.refreshTender()
  Sleep  3
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Sleep  5
  Wait Until Element Is Visible    xpath=//a[@id='edit-tender-award-item-go-button-1']
   
Wait For EscapePrequalificationButton1
  Reload Page
  Execute Javascript    tenderInformation.refreshTender()
  Sleep  3
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Sleep  5
  Wait Until Element Is Visible    xpath=//a[@id='edit-tender-award-item-escape-button-1']
   
Wait For EscapePrequalificationButton2
  Reload Page
  Execute Javascript    tenderInformation.refreshTender()
  Sleep  3
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Sleep  5
  Wait Until Element Is Visible    xpath=//a[@id='edit-tender-award-item-escape-button-2']
   
Wait For QualificationButton
  Reload Page
  Execute Javascript    tenderInformation.refreshTender()
  Sleep  3
  Дочекатися І Клікнути  xpath=//input[@value='Пропозиції']
  Sleep  5
  Wait Until Element Is Visible    xpath=//a[contains(.,'Кваліфікація')]
   
Wait For ComplaintButton
  Reload Page
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  5
  Page Should Contain Element    xpath=//a[@id='tender-complaint-edit-button-popup']

Wait For QuestionID
  [Arguments]  ${questionID}
  Reload Page
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[text()='Питання та відповіді']
  Sleep  5
  Page Should Contain Element    xpath=//a[contains(@data-prozorro-id,'${question_id}')]

Wait For Status
  Reload Page
  Sleep  3
  ${stat}=  Get Value  xpath=//*[@name='bid[status]']
  Log Many  CAT111 ${stat} 
  Page Should Contain Element    xpath=//input[@value='invalid']


Switch new lot
  [Arguments]  ${username}  ${tender_uaid}
  ukrtender.Пошук тендера по ідентифікатору    ${username}  ${tender_uaid}
  Wait Until Keyword Succeeds    180 s    10 s    subkeywords.Wait For NewLot
  Execute JavaScript                  window.scrollTo(0, 1000)
  Sleep  2
  Click Element    xpath=//*[@id='lotTabButton_2']
  Sleep  2

Подати цінову пропозицію для open
  [Arguments]  ${bid}  ${lots_ids}  ${features_ids}

  Log Many  CAT777 ${lots_ids}
  Дочекатися І Клікнути                       xpath=//input[@class='edit-bid-lot-enable']
  ${input_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@name='bid[common_cost]']  //input[@id='edit-bid-lot-cost-0']
  Wait Until Element Is Visible    xpath=${input_selector}    30
  ${float_amount}=  Set Variable If  ${NUMBER_OF_LOTS}==0  ${bid.data.value.amount}  ${bid.data.lotValues[0].value.amount}
  ${amount}=    ukrtender_service.convert_float_to_string    ${float_amount}
  Sleep  3
  Click Element    xpath=${input_selector}
  Sleep  1
  Clear Element Text    xpath=${input_selector}
  Input Text    xpath=${input_selector}    ${amount}
  ${number_lots}=    Get Length    ${bid.data.lotValues}
  ${meat}=  Evaluate  ${tender_meat} + ${lot_meat} + ${item_meat}
  ${lot_ids}=  Run Keyword If  ${lots_ids}  Set Variable  ${lots_ids}
  ...    ELSE  Create List
  Set Suite Variable    @{ID}    ${lot_ids}

  Run Keyword If    ${meat} > 0    subkeywords.Обрати неціновий показник    ${bid}    ${features_ids}
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']

Подати цінову пропозицію для below
  [Arguments]  ${bid}
  ${input_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@name='bid[common_cost]']  //input[@id='edit-bid-lot-cost-0']
  Wait Until Element Is Visible    xpath=${input_selector}    30
  ${float_amount}=  Set Variable If  ${NUMBER_OF_LOTS}==0  ${bid.data.value.amount}  ${bid.data.lotValues[0].value.amount}
  ${amount}=    ukrtender_service.convert_float_to_string    ${float_amount}
  Sleep  3
  Click Element    xpath=${input_selector}
  Sleep  1
  Clear Element Text    xpath=${input_selector}
  Input Text    xpath=${input_selector}    ${amount}

Подати цінову пропозицію для esco
  [Arguments]  ${bid}  ${lots_ids}  ${features_ids}
  Log Many  CAT777 ${bid}
  Дочекатися І Клікнути                       xpath=//input[@class='edit-bid-lot-enable']
  ${float_yearlyPaymentsPercentage}=  Set Variable  ${bid.data.lotValues[0].value.yearlyPaymentsPercentage}
  ${yearlyPaymentsPercentage}=    ukrtender_service.convert_esco__float_to_string    ${float_yearlyPaymentsPercentage}
  Sleep  1
  Input Text    xpath=//input[contains(@name,'bid[lot]') and contains(@name,'[yearly_payments_percentage]')]    ${yearlyPaymentsPercentage}
  Input Text    xpath=//input[contains(@name,'bid[lot]') and contains(@name,'[contract_duration_year]')]    ${bid.data.lotValues[0].value.contractDuration.years}
  Input Text    xpath=//input[contains(@name,'bid[lot]') and contains(@name,'[contract_duration_day]')]    ${bid.data.lotValues[0].value.contractDuration.days}
  ${reduction][0]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[0]}
  Input Text    xpath=//input[contains(@name,'reduction][0]')]    ${reduction][0]}
  ${reduction][1]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[1]}
  Input Text    xpath=//input[contains(@name,'reduction][1]')]    ${reduction][1]}
  ${reduction][2]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[2]}
  Input Text    xpath=//input[contains(@name,'reduction][2]')]    ${reduction][2]}
  ${reduction][3]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[3]}
  Input Text    xpath=//input[contains(@name,'reduction][3]')]    ${reduction][3]}
  ${reduction][4]}=    ukrtender_service.convert_float_to_string   ${bid.data.lotValues[0].value.annualCostsReduction[4]}
  Input Text    xpath=//input[contains(@name,'reduction][4]')]    ${reduction][4]}
  ${reduction][5]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[5]}
  Input Text    xpath=//input[contains(@name,'reduction][5]')]    ${reduction][5]}
  ${reduction][6]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[6]}
  Input Text    xpath=//input[contains(@name,'reduction][6]')]    ${reduction][6]}
  ${reduction][7]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[7]}
  Input Text    xpath=//input[contains(@name,'reduction][7]')]    ${reduction][7]}
  ${reduction][8]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[8]}
  Input Text    xpath=//input[contains(@name,'reduction][8]')]    ${reduction][8]}
  ${reduction][9]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[9]}
  Input Text    xpath=//input[contains(@name,'reduction][9]')]    ${reduction][9]}
  ${reduction][10]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[10]}
  Input Text    xpath=//input[contains(@name,'reduction][10]')]    ${reduction][10]}
  ${reduction][11]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[11]}
  Input Text    xpath=//input[contains(@name,'reduction][11]')]    ${reduction][11]}
  ${reduction][12]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[12]}
  Input Text    xpath=//input[contains(@name,'reduction][12]')]    ${reduction][12]}
  ${reduction][13]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[13]}
  Input Text    xpath=//input[contains(@name,'reduction][13]')]    ${reduction][13]}
  ${reduction][14]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[14]}
  Input Text    xpath=//input[contains(@name,'reduction][14]')]    ${reduction][14]}
  ${reduction][15]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[15]}
  Input Text    xpath=//input[contains(@name,'reduction][15]')]    ${reduction][15]}
  ${reduction][16]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[16]}
  Input Text    xpath=//input[contains(@name,'reduction][16]')]    ${reduction][16]}
  ${reduction][17]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[17]}
  Input Text    xpath=//input[contains(@name,'reduction][17]')]    ${reduction][17]}
  ${reduction][18]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[18]}
  Input Text    xpath=//input[contains(@name,'reduction][18]')]    ${reduction][18]}
  ${reduction][19]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[19]}
  Input Text    xpath=//input[contains(@name,'reduction][19]')]    ${reduction][19]}
  ${reduction][20]}=    ukrtender_service.convert_float_to_string    ${bid.data.lotValues[0].value.annualCostsReduction[20]}
  Input Text    xpath=//input[contains(@name,'reduction][20]')]    ${reduction][20]}
  Click Element    xpath=//input[@name='bid[absense]']
  Click Element    xpath=//input[@name='bid[confirmation]']

  ${number_lots}=    Get Length    ${bid.data.lotValues}
  ${meat}=  Evaluate  ${tender_meat} + ${lot_meat} + ${item_meat}
  ${lot_ids}=  Run Keyword If  ${lots_ids}  Set Variable  ${lots_ids}
  ...    ELSE  Create List
  Set Suite Variable    @{ID}    ${lot_ids}
  Run Keyword If    ${meat} > 0    subkeywords.Обрати неціновий показник    ${bid}    ${features_ids}

Обрати неціновий показник
  [Arguments]  ${bid}  ${features_ids}
  ${numbers_feature}=  Get Length  ${bid.data.parameters}
  ${features_ids}=  Run Keyword If  ${features_ids}  Set Variable  ${features_ids}
  ...    ELSE  Create List
  Log Many  CAT2 вошел Обрати неціновий показник ${features_ids}
  Log Many  CAT2 вошел Обрати неціновий показник 
  Log Many  CAT2 вошел Обрати неціновий показник ${bid.data.parameters[0]['value']}
  ${bid_value_lot}=    ukrtender_service.convert_float_to_string    ${bid.data.parameters[0]['value']}
  Select From List By Value  xpath=//*[@name='bid[lot_feature][0]']  ${bid_value_lot}
  ${bid_value_tenderer}=    ukrtender_service.convert_float_to_string    ${bid.data.parameters[1]['value']}
  Select From List By Value  xpath=//*[@name='bid[feature][0]']  ${bid_value_tenderer}
  ${bid_value_item}=    ukrtender_service.convert_float_to_string    ${bid.data.parameters[2]['value']}
  Select From List By Value  xpath=//*[@name='bid[item_feature][0]']  ${bid_value_item}

Отримати дані з bid below
  Click Element    xpath=//input[@value='Редагувати пропозицію']
  ${element_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@name='bid[common_cost]']  //*[@id='mForm:data:lotAmount0']
  Log Many  CAT1 ${element_selector}
  ${value}=    Get value    xpath=${element_selector}
  Log Many  CAT2 ${value}
  ${value}=    Convert To Number    ${value}
  [return]  ${value}


Отримати дані з bid open
  [Arguments]  ${field}
  ${xpath}=    get_xpath.get_bid_xpath    ${field}
#  ${xpath}=    get_xpath.get_bid_xpath    ${field}    @{ID}
  ${value}=    Get Value    xpath=${xpath}
  ${return_value}=  Run Keyword If    '${field}' != 'status'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'status'      Convert To String           ${value}
  [return]  ${return_value}


Змінити цінову пропозицію below
  [Arguments]  ${fieldvalue}
  Дочекатися І Клікнути    xpath=//*[text()="Редагувати пропозицію"]
  ${value}=                 ukrtender_service.convert_float_to_string                    ${fieldvalue}
  ${element_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@name='bid[common_cost]']  //input[@id='edit-bid-lot-cost-0']
  Clear Element Text    xpath=${element_selector}
  Sleep  1
  Input Text    xpath=${element_selector}    ${value}
  Sleep  2
  Run Keyword If    ${NUMBER_OF_LOTS}==0  Click Element    xpath=//*[@value="Редагувати пропозицію"]
  Run Keyword If    ${NUMBER_OF_LOTS}!=0  Click Element    xpath=//input[@id='edit-bid-lot-add-0']
  Sleep  15


Змінити цінову пропозицію open
  [Arguments]  ${fieldname}  ${fieldvalue}
  ${present}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//*[text()="Редагувати пропозицію"]
  Run Keyword If    ${present}    Дочекатися І Клікнути    xpath=//*[text()="Редагувати пропозицію"]
  Run Keyword If    '${fieldname}' == 'status'    subkeywords.Підтвердити пропозицію
  Run Keyword If    '${fieldname}' != 'status'    subkeywords.Змінити ставку    ${fieldname}    ${fieldvalue}


Змінити ставку
  [Arguments]  ${fieldname}  ${fieldvalue}
  ${value}=    Convert To String    ${fieldvalue}
  Log Many  CAT888 на тендер  ${fieldvalue}
  Log Many  CAT888 на тендер  ${value}
  Log Many  CAT888 на тендер  ${ID}
  ${element_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@name='bid[common_cost]']  //input[@id='edit-bid-lot-cost-0']
  Clear Element Text    xpath=${element_selector}
  Sleep  1
  Input Text    xpath=${element_selector}    ${value}
  Sleep  2
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']
  Run Keyword If    ${NUMBER_OF_LOTS}==0  Click Element    xpath=//*[@value="Подати пропозицію"]
  Run Keyword If    ${NUMBER_OF_LOTS}!=0  Scroll To Element    xpath=//input[contains(@class,'purchase edit-bid-submit-button')]
  Run Keyword If    ${NUMBER_OF_LOTS}!=0  Click Element    xpath=//input[contains(@class,'purchase edit-bid-submit-button')]
  Sleep  15


Підтвердити пропозицію
  Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Status
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']
  Дочекатися І Клікнути    xpath=//input[contains(@class,'purchase edit-bid-submit-button')]
#cat  Дочекатися І Клікнути    xpath=//*[@value="Підтвердити участь"]
  Sleep  30
  
Очікування зміни відредагованої вартості угоди
  [Arguments]   ${old_value}   ${index}
  : FOR    ${i}    IN RANGE   1   60
  \   ${result_value}=        Get Element Attribute   xpath=//span[@id="edit-tender-dialog-contract-amount"]@data-value
  \   Exit For Loop If      '${result_value}' != '${old_value}'
  \   Sleep  10
  \   Reload Page
  \   Sleep  2
  \  Дочекатися І Клікнути                       xpath=//input[@value='Пропозиції']
  \  Дочекатися І Клікнути  xpath=//a[contains(.,'Контракт') and @data-index="${index}"]
  [Return]    ${result_value}
