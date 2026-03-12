// RT 23MAY25 - Camel Case introduced for StyleWrapper class
// RT 26MAY25 - Key introduced for StyleWrapper class
// RT 29MAY25 - Label Class, Label Style, Input Class, Input Style replaced
public with sharing class StyleWrapper {
  public String id;
  public String key; // Assuming this is the external_id__c field
  public String labelClass;
  public String labelStyle;
  public String inputClass;
  public String inputStyle;
  public String inputAlign;
  public Boolean showLabel;
  public String classHeadFoot;
  public String headerSpaceStyle;
  public String footerSpaceStyle;
  public String snoHeadStyle; // RT 08OCT25 - S.no head style
  public String snoDataStyle; // RT 08OCT25 - S.no data style
  public Boolean isHead;
  public Boolean isFoot;
  public String bookStyle;
  public String fontColor;
  public Decimal fontSize;
  public String elementBorderColor;
  public String elementInputColor;
  public Decimal fieldInputSize;
  public String headingColor;
  public Decimal headingSize;
  public String labelValueStyle;
  public String elementStyle;
  public String checkboxStyle;
  public String headingStyle;
  public Decimal btnColSize;
  public String btnColStyleClass;
  public String variant;
  public Decimal btnWidth;
  public String btnStyleClass;
  public Decimal btnHeight;
  public String btnStyle;
  public String btnPosStyle;
  public String styleId;
  public String height;
  public String width;
  // VD 26Sep25 signPad changes
  public String font;
  public Decimal strokeThickness;
  public String padColor;
  public String penColor;

  public StyleWrapper(Style__c style) {
    this.id = style.Id;
    this.key = style.external_id__c; // Assuming external_id__c is used as key
    this.labelClass = style.Label_Class__c;
    this.labelStyle = style.Label_Style__c;
    this.inputClass = style.Input_Class__c;
    this.inputStyle = style.Input_Style__c;
    this.showLabel = style.showLabel__c;
    this.classHeadFoot = style.classHeadFoot__c;
    this.headerSpaceStyle = style.headerSpaceStyle__c;
    this.footerSpaceStyle = style.footerSpaceStyle__c;
    this.isHead = style.isHead__c;
    this.isFoot = style.isFoot__c;
    this.bookStyle = style.bookStyle__c;
    this.fontColor = style.Label_Color__c;
    this.fontSize = style.label_font_size__c;
    this.elementBorderColor = style.Field_Border_Color__c;
    this.elementInputColor = style.Field_Input_Color__c;
    this.fieldInputSize = style.Field_Input_Size__c;
    this.headingColor = style.Heading_Font_Color__c;
    this.headingSize = style.Heading_Size__c;
    this.snoDataStyle = style.Sno_Data_Style__c; // RT 08OCT25 - S.no data style
    this.snoHeadStyle = style.Sno_Head_Style__c; // RT 08OCT25 - S.no head style
    this.labelValueStyle = style.labelValueStyle__c;
    this.elementStyle = style.ElementStyle__c;
    this.checkboxStyle = style.CheckboxStyle__c;
    this.headingStyle = style.headingStyle__c;
    this.inputAlign = style.Input_Align__c;
    this.styleId = style.Id;
    this.height = style.height__c;
    this.width = style.width__c;
    // VD 26Sep25 signPad changes
    this.font = style.Font__c;
    this.strokeThickness = style.Stroke_Thickness__c;
    this.padColor = style.Pad_Color__c;
    this.penColor = style.Pen_Color__c;
    this.btnColSize = style.Size__c != null ? style.Size__c : 6;
    this.btnColStyleClass = style.Style_Class__c != null
      ? style.Style_Class__c
      : 'slds-size_6-of-12';
    if (style.Button_Style_Class__c != null) {
      // Deserialize the JSON string from the field
      Map<String, Object> btnStyleClassMap = (Map<String, Object>) JSON.deserializeUntyped(
        style.Button_Style_Class__c
      );
      // Assign to class variables
      this.variant = (btnStyleClassMap.containsKey('variant') &&
        btnStyleClassMap.get('variant') != null)
        ? (String) btnStyleClassMap.get('variant')
        : 'slds-button slds-button_brand';

      this.btnWidth = (btnStyleClassMap.containsKey('btnWidth') &&
        btnStyleClassMap.get('btnWidth') != null)
        ? Integer.valueOf(btnStyleClassMap.get('btnWidth'))
        : 12;

      this.btnStyleClass = (btnStyleClassMap.containsKey('btnStyleClass') &&
        btnStyleClassMap.get('btnStyleClass') != null)
        ? (String) btnStyleClassMap.get('btnStyleClass')
        : 'slds-button slds-button_brand slds-size_12-of-12';
    }
    if (style.Button_Style__c != null) {
      // Deserialize the JSON string from the field
      Map<String, Object> btnStyleMap = (Map<String, Object>) JSON.deserializeUntyped(
        style.Button_Style__c
      );
      // Assign to class variables
      this.btnHeight = (btnStyleMap.containsKey('btnHeight') &&
        btnStyleMap.get('btnHeight') != null)
        ? Integer.valueOf(btnStyleMap.get('btnHeight'))
        : 40;

      this.btnStyle = (btnStyleMap.containsKey('btnStyle') &&
        btnStyleMap.get('btnStyle') != null)
        ? (String) btnStyleMap.get('btnStyle')
        : 'box-shadow:none;height:40px;';

      this.btnPosStyle = (btnStyleMap.containsKey('btnPosStyle') &&
        btnStyleMap.get('btnPosStyle') != null)
        ? (String) btnStyleMap.get('btnPosStyle')
        : 'text-align:left;';
    }
  }

  public static List<StyleWrapper> createList(List<Style__c> styles) {
    List<StyleWrapper> wrappedStyles = new List<StyleWrapper>();
    for (Style__c style : styles) {
      wrappedStyles.add(new StyleWrapper(style));
    }
    system.debug('Stylewrapper:' + wrappedStyles);
    return wrappedStyles;
  }

  // RT 13SEP25 - Added null handling for Boolean fields
  public static Style__c loadStyleWrapper(StyleWrapper sw) {
    Style__c style = new Style__c();

    if (String.isNotEmpty(sw.id)) {
      style.Id = sw.id;
    }
    style.external_id__c = sw.key; // Assuming Id is used as external_id__c
    style.Label_Class__c = sw.labelClass;
    style.Label_Style__c = sw.labelStyle;
    style.Input_Class__c = sw.inputClass;
    style.Input_Style__c = sw.inputStyle;
    style.showLabel__c = sw.showLabel != null ? Boolean.valueOf(String.valueOf(sw.showLabel)) : false; 
    style.classHeadFoot__c = sw.classHeadFoot;
    style.headerSpaceStyle__c = sw.headerSpaceStyle;
    style.Input_Align__c = sw.inputAlign;
    style.footerSpaceStyle__c = sw.footerSpaceStyle;
    style.isHead__c = (sw.isHead != null) ? Boolean.valueOf(String.valueOf(sw.isHead)) : false;
    style.isFoot__c = (sw.isFoot != null) ? Boolean.valueOf(String.valueOf(sw.isFoot)) : false;
    style.bookStyle__c = sw.bookStyle;
    style.Label_Color__c = sw.fontColor;
    style.label_font_size__c = sw.fontSize;
    style.Field_Border_Color__c = sw.elementBorderColor;
    style.Field_Input_Color__c = sw.elementInputColor;
    style.Field_Input_Size__c = sw.fieldInputSize;
    style.Heading_Font_Color__c = sw.headingColor;
    style.Sno_Head_Style__c = sw.snoHeadStyle; // RT 08OCT25 - S.no head style
    style.Sno_Data_Style__c = sw.snoDataStyle; // RT 08OCT25 - S.no data style
    style.Heading_Size__c = sw.headingSize;
    style.labelValueStyle__c = sw.labelValueStyle;
    style.ElementStyle__c = sw.elementStyle;
    style.CheckboxStyle__c = sw.checkboxStyle;
    style.headingStyle__c = sw.headingStyle;
    style.width__c = sw.width;
    style.height__c = sw.height;
    // VD 26Sep25 signPad changes
    style.Font__c = sw.font;
    style.Stroke_Thickness__c = sw.strokeThickness;
    style.Pad_Color__c = sw.padColor;
    style.Pen_Color__c = sw.penColor;

    return style;
  }
}