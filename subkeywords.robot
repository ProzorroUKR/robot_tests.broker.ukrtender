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
  ${endDate}=           ukrtender_service.convert_date_to_string    ${fieldvalue}
  Input Text            xpath=//*[@name="tender[reception_to]"]    ${endDate}

Змінити опис
  [Arguments]  ${fieldvalue}
#cat  ${return_value}=  Get Text                     xpath=//*[@name="tender[description]"]
#cat  Log Many  CAT888 ${fieldvalue}
#cat  Log Many  CATrv ${return_value}
#cat  Click Element                       xpath=//*[@name="tender[description]"]
#cat  Scroll To Element    xpath=//*[@name="tender[description]"]
#cat  Capture Page Screenshot
#cat  Log Many  переход к tender[description]
#cat  Execute JavaScript                  window.scrollTo(0, 1000)
#cat  Log Many  переход на 1000
#cat  Capture Page Screenshot
  Clear Element Text    xpath=//*[@name="tender[description]"]
  Input Text            xpath=//*[@name="tender[description]"]    ${fieldvalue}
#cat  ${return_value}=  Get Text                     xpath=//*[@name="tender[description]"]
#cat  Log Many  CATrv2 ${return_value}
#cat  Sleep  120
#cat#cat  Click Element                       xpath=//*[text()="Редагувати закупівлю"] 

Отримати дані з поля item
  [Arguments]  ${field}  ${item_id}
  Log Many  CAT777 ${item_id}
  ${index_item}=   Execute Javascript    return $( 'input[value*="${item_id}"]' ).attr( 'name' )
  Log Many  CAT777 ${index_item}
#cat  ${index_item}=  Get Element Attribute  xpath=//input[contains(@value,"${item_id}")]@name
  ${item_index}=  split_str  ${index_item}
  ${field_xpath}=    get_xpath.get_item_xpath    ${field}    ${item_id}  ${item_index}
  Log Many  CAT888 ${field_xpath}
  ${type_field}=    get_type_field    ${field}
#cat  ${type_field}=    ukrtender_service.get_type_field    ${field}
  ${value} =  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
    ...     ELSE IF             '${type_field}' == 'text'    Get Text    ${field_xpath}

#cat  ${index_item}=  Run Keyword If    '${field}' == 'description'    Get Element Attribute  xpath=//input[contains(@value,"${item_id}")]@name
#cat  ${value} =  Run Keyword If    '${field}' == 'description'    Get Value    xpath=${index_item}
#cat  //*[@name="tender[items][0][item_name]"]
	
  [return]  ${value}

Адаптувати дані з поля item
  [Arguments]  ${field}  ${value}
  ${value}=  Run Keyword If    '${field}' == 'unit.name'    ukrtender_service.get_unit    ${field}    ${value}
    ...      ELSE IF           '${field}' == 'unit.code'    ukrtender_service.get_unit    ${field}    ${value}
    ...      ELSE IF           '${field}' == 'quantity'     Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryLocation.latitude'    Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryLocation.longitude'    Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryDate.startDate'    ukrtender_service.parse_item_date    ${value}
    ...      ELSE IF           '${field}' == 'deliveryDate.endDate'    ukrtender_service.parse_item_date    ${value}
#cat    ...      ELSE IF           '${field}' == 'classification.scheme'    Get Scheme    ${value}
    ...      ELSE               Set Variable    ${value}
  [return]  ${value}

Отримати дані з поля lot
  [Arguments]  ${field}  ${lot_id}
  ${index_lot}=   Execute Javascript    return $( 'input[value*="${lot_id}"]' ).attr( 'name' )
  Log Many  CAT777 ${index_lot}
#cat  ${index_lot}=  Get Element Attribute  xpath=//input[contains(@value,"${lot_id}")]@name
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
#  ${value}=    Get Substring    ${value}    36    38
#  ${value}=    Replace String    ${value}    ДК    CPV
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
#cat#cat  Reload page
#cat#cat  Sleep  3
#cat#cat  Scroll To Element       xpath=//span[contains(.,'Питання та відповіді')]
#cat#cat  Дочекатися І Клікнути      xpath=//span[contains(.,'Питання та відповіді')]
#cat#cat  Wait Until Element Is Visible       xpath=${field_xpath}   20 
#cat  Page Should Contain Element    xpath=${field_xpath}

Wait For TenderPeriod
  Reload Page
  Sleep  3
#cat  Page Should Contain Element    xpath=//*[text()='Очікування пропозицій']
#cat  Page Should Contain Element    xpath=//*[contains(@value, 'active.tendering')]
  Page Should Contain Element    xpath=//input[@value='active.tendering']

Wait For AuctionPeriod
  Reload Page
  Sleep  3
  Log Many  CATAuctionPeriod ${return_value}
#cat  Page Should Contain Element    xpath=//*[text()='Період аукціону']
#cat  Page Should Contain Element    xpath=//*[contains(@value, 'active.auction')]
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
#cat  Page Should Contain Element    xpath=//*[contains(@value, 'active.tendering')]
  Wait Until Page Does Not Contain Element  xpath=//input[@value='active.tendering']

Wait For QualificationsStandPeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[contains(@value, 'active.qualification')]
#cat  Wait Until Page Does Not Contain Element  xpath=//input[@value='active.tendering']

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
#cat  Page Should Contain Element    xpath=//h3[@id='tender-complaint-list-title-${complaint_index}']

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
#cat  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
#cat  Sleep  5
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
#cat  Page Should Contain Element    xpath=//*[text()='Відхилено']

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
#cat  Page Should Not Contain Element    xpath=//*[text()='Очікування пропозицій']
  ${return_value}=  Get Value  xpath=//*[@name='tender[status]']
  Log Many  CAT111 ${return_value}
#cat  Run Keyword If  '${mode}' == 'belowThreshold'  Page Should Not Contain Element    xpath=//*[@value='active.tendering']
#cat  Run Keyword If  '${mode}' != 'belowThreshold'  Page Should Not Contain Element    xpath=//*[text()='Очікування пропозицій']
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
  
  
#cat новое ########################
Wait For ClaimTender1
  [Arguments]  ${complaintID}
  Reload Page
  Sleep  3
  Execute JavaScript                  window.scrollTo(0, 0)
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Page Should Contain Element    xpath=//span[contains(text(), "${complaintID}")]/ancestor::div[contains(@aria-labelledby, "tender-complaint-list-titl")]/preceding-sibling::h3

Wait For ClaimLot1
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[2]

Wait For Answered1
  [Arguments]  ${complaintID}
  Reload Page
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  5
  Page Should Contain Element    xpath=//span[contains(text(), "${complaintID}")]/ancestor::div[contains(@aria-labelledby, "tender-complaint-list-titl")]/descendant::input[contains(@id, "tender-complaint-list-status") and @value="answered"]

Wait For Satisfied1
  [Arguments]  ${complaintID}
  Reload Page
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  5
  Page Should Contain Element    xpath=//span[contains(text(), "${complaintID}")]/ancestor::div[contains(@aria-labelledby, "tender-complaint-list-titl")]/descendant::input[contains(@id, "tender-complaint-list-status") and @value="1"]

Wait For Cancelled1
  [Arguments]  ${complaintID}
  Reload Page
  Execute JavaScript                  window.scrollTo(0, 0)
  Sleep  3
  Click Element    xpath=//span[contains(.,'Вимоги')]
  Sleep  5
  Page Should Contain Element    xpath=//span[contains(text(), "${complaintID}")]/ancestor::div[contains(@aria-labelledby, "tender-complaint-list-titl")]/descendant::input[contains(@id, "tender-complaint-list-status") and @value="cancelled"]
#cat  Page Should Contain Element    xpath=//*[text()='Відхилено']
#############################################
Wait For Status
  Reload Page
  Sleep  3
#cat  Page Should Contain Element    xpath=//*[text()='Недійсна пропозиція']
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
  ${input_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@name='bid[common_cost]']  //input[@id='edit-bid-lot-cost-0']
  Wait Until Element Is Visible    xpath=${input_selector}    30
#cat  Click Element    xpath=//*[text()="Редагувати пропозицію"]
  ${float_amount}=  Set Variable If  ${NUMBER_OF_LOTS}==0  ${bid.data.value.amount}  ${bid.data.lotValues[0].value.amount}
  ${amount}=    ukrtender_service.convert_float_to_string    ${float_amount}
#cat#cat#cat  Run Keyword If  ${NUMBER_OF_LOTS}==1  Click Element  xpath=//*[@id='mForm:data:lotData0_content']/div/button/span  # Подати пропозицію по лоту
  Sleep  3
  Click Element    xpath=${input_selector}
  Sleep  1
  Clear Element Text    xpath=${input_selector}
  Input Text    xpath=${input_selector}    ${amount}
#cat#cat#cat  Run Keyword If  ${NUMBER_OF_LOTS}==1  Click Element  xpath=//*[@id='mForm:data:lotData0_content']/div/button/span  # Подати пропозицію по лоту
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
#cat  Click Element    xpath=//*[text()="Редагувати пропозицію"]
  ${float_amount}=  Set Variable If  ${NUMBER_OF_LOTS}==0  ${bid.data.value.amount}  ${bid.data.lotValues[0].value.amount}
  ${amount}=    ukrtender_service.convert_float_to_string    ${float_amount}
#cat#cat#cat  Run Keyword If  ${NUMBER_OF_LOTS}==1  Click Element  xpath=//*[@id='mForm:data:lotData0_content']/div/button/span  # Подати пропозицію по лоту
  Sleep  3
  Click Element    xpath=${input_selector}
  Sleep  1
  Clear Element Text    xpath=${input_selector}
  Input Text    xpath=${input_selector}    ${amount}

Подати цінову пропозицію для esco
  [Arguments]  ${bid}  ${lots_ids}  ${features_ids}
  Log Many  CAT777 ${bid}
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
#cat  Click Element    xpath=//input[@name='bid[auto]']
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
#cat  Click Element    xpath=//*[@name='bid[lot_feature][0]']
  ${bid_value_lot}=    ukrtender_service.convert_float_to_string    ${bid.data.parameters[0]['value']}
  Select From List By Value  xpath=//*[@name='bid[lot_feature][0]']  ${bid_value_lot}
  ${bid_value_tenderer}=    ukrtender_service.convert_float_to_string    ${bid.data.parameters[1]['value']}
  Select From List By Value  xpath=//*[@name='bid[feature][0]']  ${bid_value_tenderer}
  ${bid_value_item}=    ukrtender_service.convert_float_to_string    ${bid.data.parameters[2]['value']}
  Select From List By Value  xpath=//*[@name='bid[item_feature][0]']  ${bid_value_item}
#cat  :FOR  ${index}  ${feature_id}  IN ENUMERATE  @{features_ids}
#cat  \  ${feature_of}=    Get Text    xpath=//*[contains(text(), '${feature_id}')]
#cat  \  ${pos}=    ukrtender_service.get_pos    ${feature_of}
#cat  \  ${value}=    ukrtender_service.get_value_feature    ${bid.data.parameters[${index}]['value']}
#  \  ${value}=    Convert To String    ${value}
#cat  \  Run Keyword If    '${feature_of}' == 'Закупівлі'    Execute JavaScript   window.scrollTo(0, 100)
#cat  \  Run Keyword If    '${feature_of}' == 'Предмету лоту'    Execute JavaScript   window.scrollTo(0, 1600)
#cat  \  Click Element    xpath=//*[contains(text(), '${feature_id}')]
#cat  \  Sleep  3
#cat  \  Click Element    xpath=(//*[contains(text(), '${value}') and @class='ui-selectonemenu-item ui-selectonemenu-list-item ui-corner-all'])[${pos}]
#  \  Wait Until Element Is Visible    xpath=//*[contains(text(), '${feature_id}')]//ancestor::tbody/tr[4]/td[2]/div//select    30
#  \  Select From List By Value    xpath=//*[contains(text(), '${feature_id}')]//ancestor::tbody/tr[4]/td[2]/div//select    ${value}


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
  ${xpath}=    get_xpath.get_bid_xpath    ${field}    @{ID}
#cat  Run Keyword If    ${field}=='status'   ${xpath}=  get_xpath.get_bid_xpath    ${field}    @{ID}
#cat  Run Keyword If    ${NUMBER_OF_LOTS}==0  and  ${field}!='status'  ${xpath}="//*[@name,'bid[common_cost]']"
#cat  Run Keyword If    ${NUMBER_OF_LOTS}!=0  and  ${field}!='status'  ${xpath}="//input[@class='edit-bid-lot-cost']"
  Log Many  CAT1 ${xpath}
  Log Many  CAT1-ID ${ID}
  ${value}=  Run Keyword If    '${field}' != 'status'    Get Value    xpath=${xpath}
  ...        ELSE IF           '${field}' == 'status'    Get Value    xpath=${xpath}
#cat  ...        ELSE IF           '${field}' == 'status'    Get Text    xpath=${xpath}
  ${return_value}=  Run Keyword If    '${field}' != 'status'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'status'      Convert To String           ${value}
#cat  ...        ELSE IF           '${field}' == 'status'    ukrtender_service.convert_bid_status    ${value}
  [return]  ${return_value}


Змінити цінову пропозицію below
  [Arguments]  ${fieldvalue}
  Дочекатися І Клікнути    xpath=//*[text()="Редагувати пропозицію"]
#cat#cat  Click Element    xpath=//input[@value='Редагувати пропозицію']
  ${value}=                 ukrtender_service.convert_float_to_string                    ${fieldvalue}
#cat  ${value}=    Convert To String    ${fieldvalue}
  ${element_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@name='bid[common_cost]']  //input[@id='edit-bid-lot-cost-0']
  Clear Element Text    xpath=${element_selector}
  Sleep  1
  Input Text    xpath=${element_selector}    ${value}
  Sleep  2
#cat  Run Keyword If    ${NUMBER_OF_LOTS}==0  Click Element    xpath=//*[@value="Подати пропозицію"]
  Run Keyword If    ${NUMBER_OF_LOTS}==0  Click Element    xpath=//*[@value="Редагувати пропозицію"]
  Run Keyword If    ${NUMBER_OF_LOTS}!=0  Click Element    xpath=//input[@id='edit-bid-lot-add-0']
  Sleep  15


Змінити цінову пропозицію open
  [Arguments]  ${fieldname}  ${fieldvalue}
  ${present}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//*[text()="Редагувати пропозицію"]
  Run Keyword If    ${present}    Дочекатися І Клікнути    xpath=//*[text()="Редагувати пропозицію"]
  Run Keyword If    '${fieldname}' == 'status'    subkeywords.Підтвердити пропозицію
#cat  Run Keyword If    ${present}    Click Element    xpath=//input[@value='Редагувати пропозицію']
  Run Keyword If    '${fieldname}' != 'status'    subkeywords.Змінити ставку    ${fieldname}    ${fieldvalue}


Змінити ставку
  [Arguments]  ${fieldname}  ${fieldvalue}
#cat  ${xpath}=    get_xpath.get_bid_xpath    ${fieldname}    @{ID}
  ${value}=    Convert To String    ${fieldvalue}
  Log Many  CAT888 на тендер  ${fieldvalue}
#cat  Log Many  CAT888 на тендер  ${xpath}
  Log Many  CAT888 на тендер  ${value}
  Log Many  CAT888 на тендер  ${ID}
#cat  Clear Element Text    xpath=${xpath}
#cat  Input Text    xpath=${xpath}    ${value}
  ${element_selector}=  Set Variable If  ${NUMBER_OF_LOTS}==0  //*[@name='bid[common_cost]']  //input[@id='edit-bid-lot-cost-0']
  Clear Element Text    xpath=${element_selector}
  Sleep  1
  Input Text    xpath=${element_selector}    ${value}
  Sleep  2
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']
  Run Keyword If    ${NUMBER_OF_LOTS}==0  Click Element    xpath=//*[@value="Подати пропозицію"]
  Run Keyword If    ${NUMBER_OF_LOTS}!=0  Scroll To Element    xpath=//input[@id='edit-bid-lot-add-0']
  Run Keyword If    ${NUMBER_OF_LOTS}!=0  Click Element    xpath=//input[@id='edit-bid-lot-add-0']
  Sleep  15


Підтвердити пропозицію
  Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Status
#cat  Click Element    xpath=//*[text()='Підтвердити пропозицію']
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[absense]']
  Run Keyword If  '${mode}' not in 'belowThreshold'  Дочекатися І Клікнути    xpath=//input[@name='bid[confirmation]']
  Дочекатися І Клікнути    xpath=//*[@value="Підтвердити участь"]
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
	
#cat Новшества из другой площадки
Add Item
    [Arguments]    ${item}    ${item_suffix}    ${d_lot}
    #Клик доб позицию
    Дочекатися І Клікнути    ${locator_add_item_button}${d_lot}
    Дочекатися І Клікнути    ${locator_item_description}${item_suffix}
    #Название предмета закупки
    Input Text    ${locator_item_description}${item_suffix}    ${item.description}
    Run Keyword And Ignore Error    Execute Javascript    angular.element(document.getElementById('divProcurementSubjectControllerEdit')).scope().procurementSubject.guid='${item.id}'
    #Количество товара
    Wait Until Element Is Enabled    ${locator_Quantity}${item_suffix}
    Input Text    ${locator_Quantity}${item_suffix}    ${item.quantity}
    #Выбор ед измерения
    Wait Until Element Is Enabled    ${locator_code}${item_suffix}
    Select From List By Value    ${locator_code}${item_suffix}    ${item.unit.code}
    ${name}=    Get From Dictionary    ${item.unit}    name
    #Выбор ДК
    Дочекатися І Клікнути    ${locator_button_add_cpv}
    Wait Until Element Is Visible    ${locator_cpv_search}    30
    Press Key    ${locator_cpv_search}    ${item.classification.id}
    Wait Until Element Is Enabled    //*[@id='tree']//li[@aria-selected="true"]    30
    Дочекатися І Клікнути    ${locator_add_classfier}
    ${is_dkpp}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${item}    additionalClassifications
    Set Suite Variable    ${dkkp_id}    000
    Run Keyword If    '${is_dkpp[0]}'=='PASS'    Get OtherDK    ${item}
    Set DKKP
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//div[@class="modal-backdrop fade"]    10
    #Срок поставки (начальная дата)
    ${date_time}=    get_aladdin_formated_date    ${item.deliveryDate.startDate}
    Fill Date    ${locator_date_delivery_start}${item_suffix}    ${date_time}
    #Срок поставки (конечная дата)
    ${date_time}=    get_aladdin_formated_date    ${item.deliveryDate.endDate}
    Fill Date    ${locator_date_delivery_end}${item_suffix}    ${date_time}
    Run Keyword And Ignore Error    Дочекатися І Клікнути    xpath=//md-switch[@id='is_delivary_${item_suffix}']/div[2]/span
    #Выбор страны
    Wait Until Element Is Visible    xpath=.//*[@id='select_countries${item_suffix}']
    Select From List By Label    xpath=.//*[@id='select_countries${item_suffix}']    ${item.deliveryAddress.countryName}
    Press Key    ${locator_postal_code}${item_suffix}    ${item.deliveryAddress.postalCode}
    aniwait
    Wait Until Element Is Enabled    id=select_regions${item_suffix}
    sleep    2
    Set Region    ${item.deliveryAddress.region}    ${item_suffix}    ${item_suffix}
    Press Key    ${locator_street}${item_suffix}    ${item.deliveryAddress.streetAddress}
    Press Key    ${locator_locality}${item_suffix}    ${item.deliveryAddress.locality}
    #Koordinate
    ${deliveryLocation_latitude}    Convert To String    ${item.deliveryLocation.latitude}
    ${deliveryLocation_latitude}    String.Replace String    ${deliveryLocation_latitude}    decimal    string
    Press Key    ${locator_deliveryLocation_latitude}${item_suffix}    ${deliveryLocation_latitude}
    ${deliveryLocation_longitude}=    Convert To String    ${item.deliveryLocation.longitude}
    ${deliveryLocation_longitude}=    String.Replace String    ${deliveryLocation_longitude}    decimal    string
    Press Key    ${locator_deliveryLocation_longitude}${item_suffix}    ${deliveryLocation_longitude}
    Run Keyword If    '${MODE}'=='openeu'    Add Item Eng    ${item}    ${item_suffix}
    #Клик кнопку "Створити"
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=.//div[@class='page-loader animated fadeIn']    5
    Wait Until Element Is Enabled    ${locator_button_create_item}${item_suffix}
    Дочекатися І Клікнути    ${locator_button_create_item}${item_suffix}  


Add Lot
    [Arguments]    ${lot_number}    ${lot}
    Дочекатися І Клікнути    ${locator_multilot_new}
    Wait Until Page Contains Element    ${locator_multilot_title}${lot_number}    30
    Wait Until Element Is Enabled    ${locator_multilot_title}${lot_number}
    Run Keyword And Ignore Error    Input Text    ${locator_multilot_title}${lot_number}    ${lot.title}
    Run Keyword If    '${MODE}'=='openeu'    Input Text    id=lotTitle_En_${lot_number}    ${lot.title_en}
    Input Text    id=lotDescription_${lot_number}    ${lot.description}
    Run Keyword And Ignore Error    Execute Javascript    angular.element(document.getElementById('divLotControllerEdit')).scope().lotPurchasePlan.guid='${lot.id}'
    ${budget}=    Get From Dictionary    ${lot.value}    amount
    ${text}=    Convert Float To String    ${budget}
    ${text}=    String.Replace String    ${text}    .    ,
    Input Text    id=lotBudget_${lot_number}    ${text}
    ${step}=    Get From Dictionary    ${lot.minimalStep}    amount
    ${text}=    Convert Float To String    ${step}
    ${text}=    String.Replace String    ${text}    .    ,
    Press Key    id=lotMinStep_${lot_number}    ${text}
    Press Key    id=lotMinStep_${lot_number}    00
    #Input Text    id=lotGuarantee_${d}
    Дочекатися І Клікнути    xpath=.//*[@id='updateOrCreateLot_1']//button[@class="btn btn-success"]
    Log To Console    finish lot ${lot_number}	