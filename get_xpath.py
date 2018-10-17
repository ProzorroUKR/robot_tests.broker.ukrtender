# coding=utf-8

def get_procurement_type_xpath(mode):
    procurement_type_xpath = {
        "belowThreshold": "//*[@value='belowThreshold']",
        "openua": "//*[@name='tender[procedure_type]_2']",
        "openeu": "//*[@name='tender[procedure_type]_3']",
        "negotiation": "//*[@name='tender[procedure_type]_6']"
    }
    return procurement_type_xpath[mode] 


def get_item_xpath(field_name, item_id, index):
    item_xpath = {
        'description': "//*[contains(@value, '" + item_id + "')]",
        'deliveryDate.startDate': "//*[contains(@name,'tender[items][" + index + "][reception_from]')]",
        'deliveryDate.endDate': "//*[contains(@name,'tender[items][" + index + "][reception_to]')]",
        'deliveryLocation.latitude': "//*[contains(@name,'tender[items][" + index + "][latitude]')]",
        'deliveryLocation.longitude': "//*[contains(@name,'tender[items][" + index + "][longitude]')]",
        'deliveryAddress.countryName': "//*[contains(@name,'tender[items][" + index + "][country]')]",
        'deliveryAddress.postalCode': "//*[contains(@name,'tender[items][" + index + "][post_index]')]",
        'deliveryAddress.region': "//*[contains(@name,'tender[items][" + index + "][region]')]",
        'deliveryAddress.locality': "//*[contains(@name,'tender[items][" + index + "][locality]')]",
        'deliveryAddress.streetAddress': "//*[contains(@name,'tender[items][" + index + "][address]')]",
        'classification.scheme': "//*[contains(@name,'tender[items][" + index + "][dk_021_2015][scheme]')]",
        'classification.id': "//*[contains(@name,'tender[items][" + index + "][dk_021_2015][id]')]",
        'classification.description': "//*[contains(@name,'tender[items][" + index + "][dk_021_2015][title]')]",
        'additionalClassifications.scheme': "//*[contains(@name,'tender[items][" + index + "][dk_moz_mnn]')]",
        'additionalClassifications.id': "//*[contains(@name,'tender[items][" + index + "][dk_moz_mnn][id]')]",
        'additionalClassifications.description': "//*[contains(text(), '" + item_id + "')][dk_moz_mnn][title]",
        'additionalClassifications[index].scheme': "//*[contains(@name,'tender[items][" + index + "][dk_moz_mnn]')]",
        'additionalClassifications[index].id': "//*[contains(@name,'tender[items][" + index + "][dk_moz_mnn][id]')]",
        'additionalClassifications[index].description': "//*[contains(text(), '" + item_id + "')][dk_moz_mnn][title]",
        'unit.name': "//*[contains(@name,'tender[items][" + index + "][unit_name]')]",
        'unit.code': "//*[contains(@name,'tender[items][" + index + "][unit]')]",
        'quantity': "//*[contains(@name,'tender[items][" + index + "][item_quantity]')]"

    }
    return item_xpath[field_name]


def get_lot_xpath(field_name, lot_id, mode):
    lot_xpath = {
	    'title': "//*[contains(@value, '" +lot_id+ "')]",
	    'description': "//*[contains(@name, 'tender[lots][" +mode+ "][description]')]",
	    'value.amount': "//*[contains(@name, 'tender[lots][" +mode+ "][amount]')]",
	    'value.currency': "//*[contains(@name, 'tender[lots][" +mode+ "][currency]')]",
	    'minimalStep.currency': "//*[contains(@name, 'tender[lots][" +mode+ "][currency]')]",
	    'value.valueAddedTaxIncluded': "//*[contains(@value, '" +mode+ "')]//ancestor::tbody/tr[9]/td[2]//td[1]//input",
	    'minimalStep.amount': "//*[contains(@name, 'tender[lots][" +mode+ "][minimal_step]')]",
	    'minimalStep.valueAddedTaxIncluded': "//*[contains(@value, '" +mode+ "')]//ancestor::tbody/tr[9]/td[2]//td[1]//input"
	}
    return lot_xpath[field_name]


def get_document_xpath(field, doc_id):
	doc_xpath = {
        'title': "//a[contains(., '"+ doc_id +"')]",
        'documentOf': "//a[contains(text(), '"+ doc_id +"')]@data-document-of",
	}
	return doc_xpath[field]


def get_question_xpath(field_name, question_id):
    question_xpath = {
        'title': "//h3[contains(., '" + question_id + "')]",
        'description': "//span[contains(@title-question-id, '" + question_id + "') and contains(@data-name,'question[description]')]",
        'answer': "//span[contains(@title-question-id, '" + question_id + "') and contains(@data-name,'question[answer]')]"
    }
    return question_xpath[field_name]


def get_claims_xpath(field_name):
	claims_xpath = {
	    'title': "//*[@id='mForm:data:title']",
	    'description': "//*[@id='mForm:data:description']",
	    'status': "//*[text()='Статус']//ancestor::tr/td[2]",
	    'resolutionType': "//*[@id='mForm:data:resolutionType_label']",
	    'resolution': "//*[@id='mForm:data:resolution']",
	    'satisfied': "//*[@id='mForm:data:satisfied_label']",
	    'complaintID': "//*[@id='mForm:NBid']",
	    'cancellationReason': "//*[@id='mForm:data:cancellationReason']"
	}
	return claims_xpath[field_name]


def get_bid_xpath(field, lot_id):
    id = lot_id[0]
    if field == 'status':
        xpath = "//*[@name='bid[status]']"
    else:
        xpath = "//input[@id='edit-bid-lot-cost-0']"
    return xpath