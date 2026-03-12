@isTest
private class StyleWrapperTest {
  @isTest
  static void testStyleWrapperMethods() {
    // Prepare sample JSON for button style fields
    String buttonStyleJson = JSON.serialize(
      new Map<String, Object>{
        'btnHeight' => 45,
        'btnStyle' => 'background-color:blue;',
        'btnPosStyle' => 'text-align:right;'
      }
    );

    String buttonStyleClassJson = JSON.serialize(
      new Map<String, Object>{
        'variant' => 'slds-button slds-button_neutral',
        'btnWidth' => 10,
        'btnStyleClass' => 'custom-class'
      }
    );

    // Create a test Style__c record
    Style__c testStyle = new Style__c(
      external_id__c = 'testKey123',
      Label_Class__c = 'label-class',
      Label_Style__c = 'color:red;',
      Input_Class__c = 'input-class',
      Input_Style__c = 'border:1px solid black;',
      showLabel__c = true,
      classHeadFoot__c = 'class-head-foot',
      headerSpaceStyle__c = 'padding-top:10px;',
      footerSpaceStyle__c = 'padding-bottom:10px;',
      isHead__c = true,
      isFoot__c = false,
      bookStyle__c = 'bold',
      Label_Color__c = '#000000',
      label_font_size__c = 14,
      Field_Border_Color__c = '#cccccc',
      Field_Input_Color__c = '#ffffff',
      Field_Input_Size__c = 12,
      Heading_Font_Color__c = '#111111',
      Heading_Size__c = 20,
      labelValueStyle__c = 'font-weight:bold;',
      ElementStyle__c = 'margin:5px;',
      CheckboxStyle__c = 'checkbox-style',
      headingStyle__c = 'heading-style',
      width__c = '100%',
      height__c = '50px',
      Size__c = 6,
      Style_Class__c = 'slds-size_6-of-12',
      Button_Style__c = buttonStyleJson,
      Button_Style_Class__c = buttonStyleClassJson
    );

    // Insert the test record to simulate behavior similar to a real org
    insert testStyle;

    // 1. Test constructor
    StyleWrapper sw = new StyleWrapper(testStyle);
    System.assertEquals('testKey123', sw.key);
    System.assertEquals('label-class', sw.labelClass);
    System.assertEquals('background-color:blue;', sw.btnStyle);
    System.assertEquals('custom-class', sw.btnStyleClass);
    System.assertEquals('slds-button slds-button_neutral', sw.variant);
    System.assertEquals(10, sw.btnWidth);
    System.assertEquals(45, sw.btnHeight);
    System.assertEquals('text-align:right;', sw.btnPosStyle);

    // 2. Test createList
    List<StyleWrapper> swList = StyleWrapper.createList(
      new List<Style__c>{ testStyle }
    );
    System.assertEquals(1, swList.size());
    System.assertEquals('label-class', swList[0].labelClass);

    // 3. Test loadStyleWrapper
    Style__c reconstructedStyle = StyleWrapper.loadStyleWrapper(sw);
    System.assertEquals(sw.key, reconstructedStyle.external_id__c);
    System.assertEquals(sw.labelClass, reconstructedStyle.Label_Class__c);
    System.assertEquals(sw.labelStyle, reconstructedStyle.Label_Style__c);
    System.assertEquals(sw.inputClass, reconstructedStyle.Input_Class__c);
  }
}