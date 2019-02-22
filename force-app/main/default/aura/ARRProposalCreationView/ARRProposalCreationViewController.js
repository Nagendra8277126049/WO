({
    init: function(component, event, helper) {
        /*		Countries via odata.
        var loadCountriesAction = component.get("c.getCountries");
        loadCountriesAction.setCallback(this, function(response, component){
            if (response.getState() === "SUCCESS") {
                component.set("v.countryOptions", response.getReturnValue()); 
            } else {
                helper.showErrorMessage(component, null, "Ohh, an error occured on loading countries information. Please, try again later.");
            }
        });
        $A.enqueueAction(loadCountriesAction); 
        */
        
		// Dummy setting of countries
		const countries = [
            { countryCode: "AF", name: "Afghanistan" },
            { countryCode: "AX", name: "Åland Islands" },
            { countryCode: "AL", name: "Albania" },
            { countryCode: "DZ", name: "Algeria" },
            { countryCode: "AS", name: "American Samoa" },
            { countryCode: "AD", name: "Andorra" },
            { countryCode: "AO", name: "Angola" },
            { countryCode: "AI", name: "Anguilla" },
            { countryCode: "AQ", name: "Antarctica" },
            { countryCode: "AG", name: "Antigua and Barbuda" },
            { countryCode: "AR", name: "Argentina" },
            { countryCode: "AM", name: "Armenia" },
            { countryCode: "AW", name: "Aruba" },
            { countryCode: "AU", name: "Australia" },
            { countryCode: "AT", name: "Austria" },
            { countryCode: "AZ", name: "Azerbaijan" },
            { countryCode: "BS", name: "Bahamas" },
            { countryCode: "BH", name: "Bahrain" },
            { countryCode: "BD", name: "Bangladesh" },
            { countryCode: "BB", name: "Barbados" },
            { countryCode: "BY", name: "Belarus" },
            { countryCode: "BE", name: "Belgium" },
            { countryCode: "BZ", name: "Belize" },
            { countryCode: "BJ", name: "Benin" },
            { countryCode: "BM", name: "Bermuda" },
            { countryCode: "BT", name: "Bhutan" },
            { countryCode: "BO", name: "Bolivia" },
            { countryCode: "BQ", name: "Bonaire" },
            { countryCode: "BA", name: "Bosnia and Herzegovina" },
            { countryCode: "BW", name: "Botswana" },
            { countryCode: "BV", name: "Bouvet Island" },
            { countryCode: "BR", name: "Brazil" },
            { countryCode: "IO", name: "British Indian Ocean Territory" },
            { countryCode: "BN", name: "Brunei Darussalam" },
            { countryCode: "BG", name: "Bulgaria" },
            { countryCode: "BF", name: "Burkina Faso" },
            { countryCode: "BI", name: "Burundi" },
            { countryCode: "KH", name: "Cambodia" },
            { countryCode: "CM", name: "Cameroon" },
            { countryCode: "CA", name: "Canada" },
            { countryCode: "CV", name: "Cape Verde" },
            { countryCode: "KY", name: "Cayman Islands" },
            { countryCode: "CF", name: "Central African Republic" },
            { countryCode: "TD", name: "Chad" },
            { countryCode: "CL", name: "Chile" },
            { countryCode: "CN", name: "China" },
            { countryCode: "CX", name: "Christmas Island" },
            { countryCode: "CC", name: "Cocos (Keeling) Islands" },
            { countryCode: "CO", name: "Colombia" },
            { countryCode: "KM", name: "Comoros" },
            { countryCode: "CG", name: "Congo" },
            { countryCode: "CD", name: "Democratic Republic of the Congo" },
            { countryCode: "CK", name: "Cook Islands" },
            { countryCode: "CR", name: "Costa Rica" },
            { countryCode: "HR", name: "Croatia" },
            { countryCode: "CU", name: "Cuba" },
            { countryCode: "CW", name: "Curacao" },
            { countryCode: "CY", name: "Cyprus" },
            { countryCode: "CZ", name: "Czech Republic" },
            { countryCode: "CI", name: "Cote d'Ivoire" },
            { countryCode: "DK", name: "Denmark" },
            { countryCode: "DJ", name: "Djibouti" },
            { countryCode: "DM", name: "Dominica" },
            { countryCode: "DO", name: "Dominican Republic" },
            { countryCode: "EC", name: "Ecuador" },
            { countryCode: "EG", name: "Egypt" },
            { countryCode: "SV", name: "El Salvador" },
            { countryCode: "GQ", name: "Equatorial Guinea" },
            { countryCode: "ER", name: "Eritrea" },
            { countryCode: "EE", name: "Estonia" },
            { countryCode: "ET", name: "Ethiopia" },
            { countryCode: "FK", name: "Falkland Islands (Malvinas)" },
            { countryCode: "FO", name: "Faroe Islands" },
            { countryCode: "FJ", name: "Fiji" },
            { countryCode: "FI", name: "Finland" },
            { countryCode: "FR", name: "France" },
            { countryCode: "GF", name: "French Guiana" },
            { countryCode: "PF", name: "French Polynesia" },
            { countryCode: "TF", name: "French Southern Territories" },
            { countryCode: "GA", name: "Gabon" },
            { countryCode: "GM", name: "Gambia" },
            { countryCode: "GE", name: "Georgia" },
            { countryCode: "DE", name: "Germany" },
            { countryCode: "GH", name: "Ghana" },
            { countryCode: "GI", name: "Gibraltar" },
            { countryCode: "GR", name: "Greece" },
            { countryCode: "GL", name: "Greenland" },
            { countryCode: "GD", name: "Grenada" },
            { countryCode: "GP", name: "Guadeloupe" },
            { countryCode: "GU", name: "Guam" },
            { countryCode: "GT", name: "Guatemala" },
            { countryCode: "GG", name: "Guernsey" },
            { countryCode: "GN", name: "Guinea" },
            { countryCode: "GW", name: "Guinea-Bissau" },
            { countryCode: "GY", name: "Guyana" },
            { countryCode: "HT", name: "Haiti" },
            { countryCode: "HM", name: "Heard Island and McDonald Islands" },
            { countryCode: "VA", name: "Holy See (The)" },
            { countryCode: "HN", name: "Honduras" },
            { countryCode: "HK", name: "Hong Kong" },
            { countryCode: "HU", name: "Hungary" },
            { countryCode: "IS", name: "Iceland" },
            { countryCode: "IN", name: "India" },
            { countryCode: "ID", name: "Indonesia" },
            { countryCode: "IF", name: "Internation Monetary Fund (IMF)" },
            { countryCode: "IR", name: "Iran (Islamic Republic of)" },
            { countryCode: "IQ", name: "Iraq" },
            { countryCode: "IE", name: "Ireland" },
            { countryCode: "IM", name: "Isle of Man" },
            { countryCode: "IL", name: "Israel" },
            { countryCode: "IT", name: "Italy" },
            { countryCode: "JM", name: "Jamaica" },
            { countryCode: "JP", name: "Japan" },
            { countryCode: "JE", name: "Jersey" },
            { countryCode: "JO", name: "Jordan" },
            { countryCode: "KZ", name: "Kazakhstan" },
            { countryCode: "KE", name: "Kenya" },
            { countryCode: "KI", name: "Kiribati" },
            { countryCode: "KP", name: "Korea, Democratic People's Republic of" },
            { countryCode: "KR", name: "Korea, Republic of" },
            { countryCode: "KW", name: "Kuwait" },
            { countryCode: "KG", name: "Kyrgyzstan" },
            { countryCode: "LA", name: "Lao People's Democratic Republic (The)" },
            { countryCode: "LV", name: "Latvia" },
            { countryCode: "LB", name: "Lebanon" },
            { countryCode: "LS", name: "Lesotho" },
            { countryCode: "LR", name: "Liberia" },
            { countryCode: "LY", name: "Libya" },
            { countryCode: "LI", name: "Liechtenstein" },
            { countryCode: "LT", name: "Lithuania" },
            { countryCode: "LU", name: "Luxembourg" },
            { countryCode: "MO", name: "Macao" },
            { countryCode: "MK", name: "Macedonia, the Former Yugoslav Republic of" },
            { countryCode: "MG", name: "Madagascar" },
            { countryCode: "MW", name: "Malawi" },
            { countryCode: "MY", name: "Malaysia" },
            { countryCode: "MV", name: "Maldives" },
            { countryCode: "ML", name: "Mali" },
            { countryCode: "MT", name: "Malta" },
            { countryCode: "MH", name: "MARSHALL ISLANDS (THE)" },
            { countryCode: "MQ", name: "Martinique" },
            { countryCode: "MR", name: "Mauritania" },
            { countryCode: "MU", name: "Mauritius" },
            { countryCode: "YT", name: "Mayotte" },
            { countryCode: "XU", name: "MEMBER COUNTRIES OF THE AFRICAN DEVELOPMENT BANK GROUP"},
            { countryCode: "MX", name: "Mexico" },
            { countryCode: "FM", name: "Micronesia (Federated States Of)" },
            { countryCode: "MD", name: "Moldova, Republic of" },
            { countryCode: "MC", name: "Monaco" },
            { countryCode: "MN", name: "Mongolia" },
            { countryCode: "ME", name: "Montenegro" },
            { countryCode: "MS", name: "Montserrat" },
            { countryCode: "MA", name: "Morocco" },
            { countryCode: "MZ", name: "Mozambique" },
            { countryCode: "MM", name: "Myanmar" },
            { countryCode: "NA", name: "Namibia" },
            { countryCode: "NR", name: "Nauru" },
            { countryCode: "NP", name: "Nepal" },
            { countryCode: "NL", name: "Netherlands (The)" },
            { countryCode: "NC", name: "New Caledonia" },
            { countryCode: "NZ", name: "New Zealand" },
            { countryCode: "NI", name: "Nicaragua" },
            { countryCode: "NE", name: "Niger (The)" },
            { countryCode: "NG", name: "Nigeria" },
            { countryCode: "NU", name: "Niue" },
            { countryCode: "NF", name: "Norfolk Island" },
            { countryCode: "MP", name: "Northern Mariana Islands (The)" },
            { countryCode: "NO", name: "Norway" },
            { countryCode: "OM", name: "Oman" },
            { countryCode: "PK", name: "Pakistan" },
            { countryCode: "PW", name: "Palau" },
            { countryCode: "PS", name: "Palestine, State of" },
            { countryCode: "PA", name: "Panama" },
            { countryCode: "PG", name: "Papua New Guinea" },
            { countryCode: "PY", name: "Paraguay" },
            { countryCode: "PE", name: "Peru" },
            { countryCode: "PH", name: "Philippines" },
            { countryCode: "PN", name: "Pitcairn" },
            { countryCode: "PL", name: "Poland" },
            { countryCode: "PT", name: "Portugal" },
            { countryCode: "PR", name: "Puerto Rico" },
            { countryCode: "QA", name: "Qatar" },
            { countryCode: "RO", name: "Romania" },
            { countryCode: "RU", name: "Russian Federation" },
            { countryCode: "RW", name: "Rwanda" },
            { countryCode: "RE", name: "Réunion" },
            { countryCode: "BL", name: "Saint Barthélemy" },
            { countryCode: "SH", name: "Saint Helena, Ascension and Tristan" },
            { countryCode: "KN", name: "Saint Kitts and Nevis" },
            { countryCode: "LC", name: "Saint Lucia" },
            { countryCode: "MF", name: "Saint Martin (French part)" },
            { countryCode: "PM", name: "Saint Pierre and Miquelon" },
            { countryCode: "VC", name: "Saint Vincent and the Grenadines" },
            { countryCode: "WS", name: "Samoa" },
            { countryCode: "SM", name: "San Marino" },
            { countryCode: "ST", name: "Sao Tome and Principe" },
            { countryCode: "SA", name: "Saudi Arabia" },
            { countryCode: "SN", name: "Senegal" },
            { countryCode: "RS", name: "Serbia" },
            { countryCode: "SC", name: "Seychelles" },
            { countryCode: "SL", name: "Sierra Leone" },
            { countryCode: "SG", name: "Singapore" },
            { countryCode: "SX", name: "Sint Maarten (Dutch part)" },
            { countryCode: "SK", name: "Slovakia" },
            { countryCode: "SI", name: "Slovenia" },
            { countryCode: "SB", name: "Solomon Islands" },
            { countryCode: "SO", name: "Somalia" },
            { countryCode: "ZA", name: "South Africa" },
            { countryCode: "GS", name: "South Georgia and the South Sandwich Islands" },
            { countryCode: "SS", name: "South Sudan" },
            { countryCode: "ES", name: "Spain" },
            { countryCode: "LK", name: "Sri Lanka" },
            { countryCode: "SD", name: "Sudan" },
            { countryCode: "SR", name: "Suriname" },
            { countryCode: "SJ", name: "Svalbard and Jan Mayen" },
            //{ countryCode: "SZ", name: "Swaziland" },
            { countryCode: "SE", name: "Sweden" },
            { countryCode: "CH", name: "Switzerland" },
            { countryCode: "SY", name: "Syrian Arab Republic" },
            { countryCode: "TW", name: "Taiwan" },
            { countryCode: "TJ", name: "Tajikistan" },
            { countryCode: "TZ", name: "Tanzania, United Republic of" },
            { countryCode: "TH", name: "Thailand" },
            { countryCode: "TL", name: "Timor-Leste" },
            { countryCode: "TG", name: "Togo" },
            { countryCode: "TK", name: "Tokelau" },
            { countryCode: "TO", name: "Tonga" },
            { countryCode: "TT", name: "Trinidad and Tobago" },
            { countryCode: "TN", name: "Tunisia" },
            { countryCode: "TR", name: "Turkey" },
            { countryCode: "TM", name: "Turkmenistan" },
            { countryCode: "TC", name: "Turks and Caicos Islands" },
            { countryCode: "TV", name: "Tuvalu" },
            { countryCode: "UG", name: "Uganda" },
            { countryCode: "UA", name: "Ukraine" },
            { countryCode: "AE", name: "United Arab Emirates" },
            { countryCode: "GB", name: "United Kingdom" },
            { countryCode: "US", name: "United States of America (the)" },
            { countryCode: "UM", name: "UNITED STATES MINOR OUTLYING ISLANDS (THE)" },
            { countryCode: "UY", name: "Uruguay" },
            { countryCode: "UZ", name: "Uzbekistan" },
            { countryCode: "VU", name: "Vanuatu" },
            { countryCode: "VE", name: "Venezuela" },
            { countryCode: "VN", name: "Viet Nam" },
            { countryCode: "VG", name: "British Virgin Islands" },
            { countryCode: "VI", name: "US Virgin Islands" },
            { countryCode: "WF", name: "Wallis and Futuna" },
            { countryCode: "EH", name: "Western Sahara" },
            { countryCode: "YE", name: "Yemen" },
            { countryCode: "ZM", name: "Zambia" },
            { countryCode: "ZW", name: "Zimbabwe" },


            
            
            /*{ countryCode: "US", name: "United States" },
            { countryCode: "CA", name: "Canada" },
            { countryCode: "BR", name: "Brazil" },
            */
        ];
        
        component.set("v.countryOptions", countries);
        
        // Init Qualified Questions options
        var brandsAction = component.get("c.getBrands");
        brandsAction.setCallback(this, function(response, component){
            if (response.getState() === "SUCCESS") {
                try {
                    var result = response.getReturnValue();
                    
                    if (result.Status != 200) {
                        helper.showErrorMessage(component, null, helper.formatErrorMessageType(result.Body));
                    } else
                        component.set("v.brandOptions", JSON.parse(result.Body)); 
                }
                catch (e) {
                    helper.showErrorMessage(component, null);
                }
            } else {
                helper.showErrorMessage(component);
            }
        });
        $A.enqueueAction(brandsAction);
        
        var typesAction = component.get("c.getTypes");
        typesAction.setCallback(this, function(response, component){
            if (response.getState() === "SUCCESS") {
                try {
                    var result = response.getReturnValue();
                    
                    if (result.Status != 200) {
                        helper.showErrorMessage(component, null, helper.formatErrorMessageType(result.Body));
                    } else
                        component.set("v.typeOptions", JSON.parse(result.Body)); 
                }
                catch (e) {
                    helper.showErrorMessage(component, null);
                }
            } else {
                helper.showErrorMessage(component);
            }
        });
        $A.enqueueAction(typesAction);
        
        var processorsAction = component.get("c.getProcessors");
        processorsAction.setCallback(this, function(response, component){
            if (response.getState() === "SUCCESS") {
                try {
                    var result = response.getReturnValue();
                    
                    if (result.Status != 200) {
                        helper.showErrorMessage(component, null, helper.formatErrorMessageType(result.Body));
                    } else
                        component.set("v.processorOptions", JSON.parse(result.Body)); 
                }
                catch (e) {
                    helper.showErrorMessage(component, null);
                }
            } else {
                helper.showErrorMessage(component);
            }
        });
        $A.enqueueAction(processorsAction);
    },
    handleCountryChange: function(component, event, helper) {
        const country = component.get("v.countryInput");
            
        // Dummy values for currency and state setting
        const states = [
            { country: "CA" ,stateCode: "AB", name: "Alberta" },
            { country: "CA" ,stateCode: "BC", name: "British Columbia" },
            { country: "CA" ,stateCode: "MB", name: "Manitoba" },
            { country: "CA" ,stateCode: "NB", name: "New Brunswick" },
            { country: "CA" ,stateCode: "NL", name: "Newfoundland and Labrador" },
            { country: "CA" ,stateCode: "NS", name: "Nova Scotia" },
            { country: "CA" ,stateCode: "ON", name: "Ontario" },
            { country: "CA" ,stateCode: "PE", name: "Prince Edward Island" },
            { country: "CA" ,stateCode: "QC", name: "Quebec" },
            { country: "CA" ,stateCode: "SK", name: "Saskatchewan" },
            { country: "CA" ,stateCode: "NT", name: "Northwest Territories" },
            { country: "CA" ,stateCode: "NU", name: "Nunavut" },
            { country: "CA" ,stateCode: "YT", name: "Yukon" },
            { country: "US", stateCode: "AL", name: "Alabama" },
            { country: "US", stateCode: "AL", name: "Alabama" },
            { country: "US", stateCode: "AK", name: "Alaska" },
            { country: "US", stateCode: "AZ", name: "Arizona" },
            { country: "US", stateCode: "AR", name: "Arkansas" },
            { country: "US", stateCode: "CA", name: "California" },
            { country: "US", stateCode: "CO", name: "Colorado" },
            { country: "US", stateCode: "CT", name: "Connecticut" },
            { country: "US", stateCode: "DE", name: "Delaware" },
            { country: "US", stateCode: "FL", name: "Florida" },
            { country: "US", stateCode: "GA", name: "Georgia" },
            { country: "US", stateCode: "HI", name: "Hawaii" },
            { country: "US", stateCode: "ID", name: "Idaho" },
            { country: "US", stateCode: "IL", name: "Illinois" },
            { country: "US", stateCode: "IN", name: "Indiana" },
            { country: "US", stateCode: "IA", name: "Iowa" },
            { country: "US", stateCode: "KS", name: "Kansas" },
            { country: "US", stateCode: "KY", name: "Kentucky" },
            { country: "US", stateCode: "LA", name: "Louisiana" },
            { country: "US", stateCode: "ME", name: "Maine" },
            { country: "US", stateCode: "MD", name: "Maryland" },
            { country: "US", stateCode: "MA", name: "Massachusetts" },
            { country: "US", stateCode: "MI", name: "Michigan" },
            { country: "US", stateCode: "MN", name: "Minnesota" },
            { country: "US", stateCode: "MS", name: "Mississippi" },
            { country: "US", stateCode: "MO", name: "Missouri" },
            { country: "US", stateCode: "MT", name: "Montana" },
            { country: "US", stateCode: "NE", name: "Nebraska" },
            { country: "US", stateCode: "NV", name: "Nevada" },
            { country: "US", stateCode: "NH", name: "New Hampshire" },
            { country: "US", stateCode: "NJ", name: "New Jersey" },
            { country: "US", stateCode: "NM", name: "New Mexico" },
            { country: "US", stateCode: "NY", name: "New York" },
            { country: "US", stateCode: "NC", name: "North Carolina" },
            { country: "US", stateCode: "ND", name: " North Dakota" },
            { country: "US", stateCode: "OH", name: "Ohio" },
            { country: "US", stateCode: "OK", name: "Oklahoma" },
            { country: "US", stateCode: "OR", name: "Oregon" },
            { country: "US", stateCode: "PA", name: "Pennsylvania" },
            { country: "US", stateCode: "RI", name: "Rhode Island" },
            { country: "US", stateCode: "SC", name: "South Carolina" },
            { country: "US", stateCode: "SD", name: "South Dakota" },
            { country: "US", stateCode: "TN", name: "Tennessee" },
            { country: "US", stateCode: "TX", name: "Texas" },
            { country: "US", stateCode: "UT", name: "Utah" },
            { country: "US", stateCode: "VT", name: "Vermont" },
            { country: "US", stateCode: "VA", name: "Virginia" },
            { country: "US", stateCode: "WA", name: "Washington" },
            { country: "US", stateCode: "WV", name: "West Virginia" },
            { country: "US", stateCode: "WI", name: "Wisconsin" },
            { country: "US", stateCode: "WY", name: "Wyoming" },
            { country: "US", stateCode: "DC", name: "District of Columbia" },
            { country: "US", stateCode: "AS", name: "American Samoa" },
            { country: "US", stateCode: "GU", name: "Guam" },
            { country: "US", stateCode: "MP", name: "Northern Mariana Islands" },
            { country: "US", stateCode: "PR", name: "Puerto Rico" },
            { country: "US", stateCode: "UM", name: "United States Minor Outlying Islands" },
            { country: "US", stateCode: "VI", name: "Virgin Islands U.S"},
            { country: "CN", stateCode: "AH", name: "Hefei" },
            { country: "CN", stateCode: "BJ", name: "Beijing" },
            { country: "CN", stateCode: "CQ", name: "Chongqing" },
            { country: "CN", stateCode: "FJ", name: "Fuzhou" },
            { country: "CN", stateCode: "GD", name: "Guangzhou" },
            { country: "CN", stateCode: "GS", name: "Lanzhou" },
            { country: "CN", stateCode: "GX", name: "Nanning" },
            { country: "CN", stateCode: "GZ", name: "Guiyang" },
            { country: "CN", stateCode: "HA (HEN)", name: "Zhengzhou" },
            { country: "CN", stateCode: "HB (HUB)", name: "Wuhan" },
            { country: "CN", stateCode: "HE (HEB)", name: "Shijiazhuang" },
            { country: "CN", stateCode: "HI", name: "Haikou" },
            { country: "CN", stateCode: "HK", name: "Hong Kong" },
            { country: "CN", stateCode: "HL", name: "Harbin" },
            { country: "CN", stateCode: "HN (HUN)", name: "Changsha" },
            { country: "CN", stateCode: "JL", name: "Changchun" },
            { country: "CN", stateCode: "JS", name: "Nanjing" },
            { country: "CN", stateCode: "JX", name: "Nanchang" },
            { country: "CN", stateCode: "LN", name: "Shenyang" },
            { country: "CN", stateCode: "MO", name: "Macau" },
            { country: "CN", stateCode: "NM", name: "Hohhot" },
            { country: "CN", stateCode: "NX", name: "Yinchuan" },
            { country: "CN", stateCode: "QH", name: "Xining" },
            { country: "CN", stateCode: "SC", name: "Chengdu" },
            { country: "CN", stateCode: "SD", name: "Jinan" },
            { country: "CN", stateCode: "SH", name: "Shanghai" },
            { country: "CN", stateCode: "SN (SAA)", name: "Xi'an" },
            { country: "CN", stateCode: "SX (SAX)", name: "Taiyuan" },
            { country: "CN", stateCode: "TJ", name: "Tianjin" },
            { country: "CN", stateCode: "TW", name: "Taipei" },
            { country: "CN", stateCode: "XJ", name: "Ürümqi" },
            { country: "CN", stateCode: "XZ", name: "Lhasa" },
            { country: "CN", stateCode: "YN", name: "Kunming" },
            { country: "CN", stateCode: "ZJ", name: "Hangzhou" }

        ];
        
        const currencies = [
            /*{ country: "US", currencyCode: "USD", name: "US Dollar" },  
            { country: "CA", currencyCode: "CAD", name: "Canadian Dollar" },
            { country: "BR", currencyCode: "BRL", name: "Brazilian Real" } 
            */
            { country: "AF", currencyCode: "AFN", name: "Afghani" },
            { country: "AX", currencyCode: "EUR", name: "Euro" },
            { country: "AL", currencyCode: "ALL", name: "Lek" },
            { country: "DZ", currencyCode: "DZD", name: "Algerian Dinar" },
            { country: "AS", currencyCode: "USD", name: "US Dollar" },
            { country: "VG", currencyCode: "USD", name: "US Dollar" },
            { country: "VI", currencyCode: "USD", name: "US Dollar" },
            { country: "AD", currencyCode: "EUR", name: "Euro" },
            { country: "AO", currencyCode: "AOA", name: "Kwanza" },
            { country: "AI", currencyCode: "XCD", name: "East Caribbean Dollar" },
            { country: "AQ", currencyCode: "", name: "No universal currency" },
            { country: "AG", currencyCode: "XCD", name: "East Caribbean Dollar" },
            { country: "AR", currencyCode: "ARS", name: "Argentine Peso" },
            { country: "AM", currencyCode: "AMD", name: "Armenian Dram" },
            { country: "AW", currencyCode: "AWG", name: "Aruban Florin" },
            { country: "AU", currencyCode: "AUD", name: "Australian Dollar" },
            { country: "AT", currencyCode: "EUR", name: "Euro" },
            { country: "AZ", currencyCode: "AZN", name: "Azerbaijan Manat" },
            { country: "BS", currencyCode: "BSD", name: "Bahamian Dollar" },
            { country: "BH", currencyCode: "BHD", name: "Bahraini Dinar" },
            { country: "BD", currencyCode: "BDT", name: "Taka" },
            { country: "BB", currencyCode: "BBD", name: "Barbados Dollar" },
            { country: "BY", currencyCode: "BYN", name: "Belarusian Ruble" },
            { country: "BE", currencyCode: "EUR", name: "Euro" },
            { country: "BZ", currencyCode: "BZD", name: "Belize Dollar" },
            { country: "BJ", currencyCode: "XOF", name: "CFA Franc BCEAO" },
            { country: "BM", currencyCode: "BMD", name: "Bermudian Dollar" },
            { country: "BT", currencyCode: "INR", name: "Indian Rupee" },
            { country: "BT", currencyCode: "BTN", name: "Ngultrum" },
            { country: "BO", currencyCode: "BOB", name: "Boliviano" },
            { country: "BO", currencyCode: "BOV", name: "Mvdol" },
            { country: "BQ", currencyCode: "USD", name: "US Dollar" },
            { country: "BA", currencyCode: "BAM", name: "Convertible Mark" },
            { country: "BW", currencyCode: "BWP", name: "Pula" },
            { country: "BV", currencyCode: "NOK", name: "Norwegian Krone" },
            { country: "BR", currencyCode: "BRL", name: "Brazilian Real" },
            { country: "IO", currencyCode: "USD", name: "US Dollar" },
            { country: "BN", currencyCode: "BND", name: "Brunei Dollar" },
            { country: "BG", currencyCode: "BGN", name: "Bulgarian Lev" },
            { country: "BF", currencyCode: "XOF", name: "CFA Franc BCEAO" },
            { country: "BI", currencyCode: "BIF", name: "Burundi Franc" },
            { country: "CV", currencyCode: "CVE", name: "Cabo Verde Escudo" },
            { country: "KH", currencyCode: "KHR", name: "Riel" },
            { country: "CM", currencyCode: "XAF", name: "CFA Franc BEAC" },
            { country: "CA", currencyCode: "CAD", name: "Canadian Dollar" },
            { country: "KY", currencyCode: "KYD", name: "Cayman Islands Dollar" },
            { country: "CF", currencyCode: "XAF", name: "CFA Franc BEAC" },
            { country: "TD", currencyCode: "XAF", name: "CFA Franc BEAC" },
            { country: "CL", currencyCode: "CLP", name: "Chilean Peso" },
            { country: "CL", currencyCode: "CLF", name: "Unidad de Fomento" },
            { country: "CN", currencyCode: "CNY", name: "Yuan Renminbi" },
            { country: "CX", currencyCode: "AUD", name: "Australian Dollar" },
            { country: "CC", currencyCode: "AUD", name: "Australian Dollar" },
            { country: "CO", currencyCode: "COP", name: "Colombian Peso" },
            { country: "CO", currencyCode: "COU", name: "Unidad de Valor Real" },
            { country: "KM", currencyCode: "KMF", name: "Comorian Franc " },
            { country: "CD", currencyCode: "CDF", name: "Congolese Franc" },
            { country: "CG", currencyCode: "XAF", name: "CFA Franc BEAC" },
            { country: "CK", currencyCode: "NZD", name: "New Zealand Dollar" },
            { country: "CR", currencyCode: "CRC", name: "Costa Rican Colon" },
            { country: "CI", currencyCode: "XOF", name: "CFA Franc BCEAO" },
            { country: "HR", currencyCode: "HRK", name: "Kuna" },
            { country: "CU", currencyCode: "CUP", name: "Cuban Peso" },
            { country: "CU", currencyCode: "CUC", name: "Peso Convertible" },
            { country: "CW", currencyCode: "ANG", name: "Netherlands Antillean Guilder" },
            { country: "CY", currencyCode: "EUR", name: "Euro" },
            { country: "CZ", currencyCode: "CZK", name: "Czech Koruna" },
            { country: "DK", currencyCode: "DKK", name: "Danish Krone" },
            { country: "DJ", currencyCode: "DJF", name: "Djibouti Franc" },
            { country: "DM", currencyCode: "XCD", name: "East Caribbean Dollar" },
            { country: "DO", currencyCode: "DOP", name: "Dominican Peso" },
            { country: "EC", currencyCode: "USD", name: "US Dollar" },
            { country: "EG", currencyCode: "EGP", name: "Egyptian Pound" },
            { country: "SV", currencyCode: "SVC", name: "El Salvador Colon" },
            { country: "SV", currencyCode: "USD", name: "US Dollar" },
            { country: "GQ", currencyCode: "XAF", name: "CFA Franc BEAC" },
            { country: "ER", currencyCode: "ERN", name: "Nakfa" },
            { country: "EE", currencyCode: "EUR", name: "Euro" },
            { country: "ET", currencyCode: "ETB", name: "Ethiopian Birr" },
            { country: "EU", currencyCode: "EUR", name: "Euro" },
            { country: "FK", currencyCode: "FKP", name: "Falkland Islands Pound" },
            { country: "FO", currencyCode: "DKK", name: "Danish Krone" },
            { country: "FJ", currencyCode: "FJD", name: "Fiji Dollar" },
            { country: "FI", currencyCode: "EUR", name: "Euro" },
            { country: "FR", currencyCode: "EUR", name: "Euro" },
            { country: "GF", currencyCode: "EUR", name: "Euro" },
            { country: "PF", currencyCode: "XPF", name: "CFP Franc" },
            { country: "TF", currencyCode: "EUR", name: "Euro" },
            { country: "GA", currencyCode: "XAF", name: "CFA Franc BEAC" },
            { country: "GM", currencyCode: "GMD", name: "Dalasi" },
            { country: "GE", currencyCode: "GEL", name: "Lari" },
            { country: "DE", currencyCode: "EUR", name: "Euro" },
            { country: "GH", currencyCode: "GHS", name: "Ghana Cedi" },
            { country: "GI", currencyCode: "GIP", name: "Gibraltar Pound" },
            { country: "GR", currencyCode: "EUR", name: "Euro" },
            { country: "GL", currencyCode: "DKK", name: "Danish Krone" },
            { country: "GD", currencyCode: "XCD", name: "East Caribbean Dollar" },
            { country: "GP", currencyCode: "EUR", name: "Euro" },
            { country: "GU", currencyCode: "USD", name: "US Dollar" },
            { country: "GT", currencyCode: "GTQ", name: "Quetzal" },
            { country: "GG", currencyCode: "GBP", name: "Pound Sterling" },
            { country: "GN", currencyCode: "GNF", name: "Guinean Franc" },
            { country: "GW", currencyCode: "XOF", name: "CFA Franc BCEAO" },
            { country: "GY", currencyCode: "GYD", name: "Guyana Dollar" },
            { country: "HT", currencyCode: "HTG", name: "Gourde" },
            { country: "HT", currencyCode: "USD", name: "US Dollar" },
            { country: "HM", currencyCode: "AUD", name: "Australian Dollar" },
            { country: "VA", currencyCode: "EUR", name: "Euro" },
            { country: "HN", currencyCode: "HNL", name: "Lempira" },
            { country: "HK", currencyCode: "HKD", name: "Hong Kong Dollar" },
            { country: "HU", currencyCode: "HUF", name: "Forint" },
            { country: "IS", currencyCode: "ISK", name: "Iceland Krona" },
            { country: "IN", currencyCode: "INR", name: "Indian Rupee" },
            { country: "ID", currencyCode: "IDR", name: "Rupiah" },
            { country: "IF", currencyCode: "XDR", name: "SDR (Special Drawing Right)" },
            { country: "IR", currencyCode: "IRR", name: "Iranian Rial" },
            { country: "IQ", currencyCode: "IQD", name: "Iraqi Dinar" },
            { country: "IE", currencyCode: "EUR", name: "Euro" },
            { country: "IM", currencyCode: "GBP", name: "Pound Sterling" },
            { country: "IL", currencyCode: "ILS", name: "New Israeli Sheqel" },
            { country: "IT", currencyCode: "EUR", name: "Euro" },
            { country: "JM", currencyCode: "JMD", name: "Jamaican Dollar" },
            { country: "JP", currencyCode: "JPY", name: "Yen" },
            { country: "JE", currencyCode: "GBP", name: "Pound Sterling" },
            { country: "JO", currencyCode: "JOD", name: "Jordanian Dinar" },
            { country: "KZ", currencyCode: "KZT", name: "Tenge" },
            { country: "KE", currencyCode: "KES", name: "Kenyan Shilling" },
            { country: "KI", currencyCode: "AUD", name: "Australian Dollar" },
            { country: "KP", currencyCode: "KPW", name: "North Korean Won" },
            { country: "KR", currencyCode: "KRW", name: "Won" },
            { country: "KW", currencyCode: "KWD", name: "Kuwaiti Dinar" },
            { country: "KG", currencyCode: "KGS", name: "Som" },
            { country: "LA", currencyCode: "LAK", name: "Lao Kip" },
            { country: "LV", currencyCode: "EUR", name: "Euro" },
            { country: "LB", currencyCode: "LBP", name: "Lebanese Pound" },
            { country: "LS", currencyCode: "LSL", name: "Loti" },
            { country: "LS", currencyCode: "ZAR", name: "Rand" },
            { country: "LR", currencyCode: "LRD", name: "Liberian Dollar" },
            { country: "LY", currencyCode: "LYD", name: "Libyan Dinar" },
            { country: "LI", currencyCode: "CHF", name: "Swiss Franc" },
            { country: "LT", currencyCode: "EUR", name: "Euro" },
            { country: "LU", currencyCode: "EUR", name: "Euro" },
            { country: "MO", currencyCode: "MOP", name: "Pataca" },
            { country: "MK", currencyCode: "MKD", name: "Denar" },
            { country: "MG", currencyCode: "MGA", name: "Malagasy Ariary" },
            { country: "MW", currencyCode: "MWK", name: "Malawi Kwacha" },
            { country: "MY", currencyCode: "MYR", name: "Malaysian Ringgit" },
            { country: "MV", currencyCode: "MVR", name: "Rufiyaa" },
            { country: "ML", currencyCode: "XOF", name: "CFA Franc BCEAO" },
            { country: "MT", currencyCode: "EUR", name: "Euro" },
            { country: "MH", currencyCode: "USD", name: "US Dollar" },
            { country: "MQ", currencyCode: "EUR", name: "Euro" },
            { country: "MR", currencyCode: "MRU", name: "Ouguiya" },
            { country: "MU", currencyCode: "MUR", name: "Mauritius Rupee" },
            { country: "YT", currencyCode: "EUR", name: "Euro" },
            { country: "MX", currencyCode: "MXN", name: "Mexican Peso" },
            { country: "MX", currencyCode: "MXV", name: "Mexican Unidad de Inversion (UDI)" },
            { country: "FM", currencyCode: "USD", name: "US Dollar" },
            { country: "MD", currencyCode: "MDL", name: "Moldovan Leu" },
            { country: "MC", currencyCode: "EUR", name: "Euro" },
            { country: "MN", currencyCode: "MNT", name: "Tugrik" },
            { country: "ME", currencyCode: "EUR", name: "Euro" },
            { country: "MS", currencyCode: "XCD", name: "East Caribbean Dollar" },
            { country: "MA", currencyCode: "MAD", name: "Moroccan Dirham" },
            { country: "MZ", currencyCode: "MZN", name: "Mozambique Metical" },
            { country: "MM", currencyCode: "MMK", name: "Kyat" },
            { country: "NA", currencyCode: "NAD", name: "Namibia Dollar" },
            { country: "NA", currencyCode: "ZAR", name: "Rand" },
            { country: "NR", currencyCode: "AUD", name: "Australian Dollar" },
            { country: "NP", currencyCode: "NPR", name: "Nepalese Rupee" },
            { country: "NL", currencyCode: "EUR", name: "Euro" },
            { country: "NC", currencyCode: "XPF", name: "CFP Franc" },
            { country: "NZ", currencyCode: "NZD", name: "New Zealand Dollar" },
            { country: "NI", currencyCode: "NIO", name: "Cordoba Oro" },
            { country: "NE", currencyCode: "XOF", name: "CFA Franc BCEAO" },
            { country: "NG", currencyCode: "NGN", name: "Naira" },
            { country: "NU", currencyCode: "NZD", name: "New Zealand Dollar" },
            { country: "NF", currencyCode: "AUD", name: "Australian Dollar" },
            { country: "MP", currencyCode: "USD", name: "US Dollar" },
            { country: "NO", currencyCode: "NOK", name: "Norwegian Krone" },
            { country: "OM", currencyCode: "OMR", name: "Rial Omani" },
            { country: "PK", currencyCode: "PKR", name: "Pakistan Rupee" },
            { country: "PW", currencyCode: "USD", name: "US Dollar" },
            { country: "PS", currencyCode: "", name: "No universal currency" },
            { country: "PA", currencyCode: "PAB", name: "Balboa" },
            { country: "PA", currencyCode: "USD", name: "US Dollar" },
            { country: "PG", currencyCode: "PGK", name: "Kina" },
            { country: "PY", currencyCode: "PYG", name: "Guarani" },
            { country: "PE", currencyCode: "PEN", name: "Sol" },
            { country: "PH", currencyCode: "PHP", name: "Philippine Peso" },
            { country: "PN", currencyCode: "NZD", name: "New Zealand Dollar" },
            { country: "PL", currencyCode: "PLN", name: "Zloty" },
            { country: "PT", currencyCode: "EUR", name: "Euro" },
            { country: "PR", currencyCode: "USD", name: "US Dollar" },
            { country: "QA", currencyCode: "QAR", name: "Qatari Rial" },
            { country: "RE", currencyCode: "EUR", name: "Euro" },
            { country: "RO", currencyCode: "RON", name: "Romanian Leu" },
            { country: "RU", currencyCode: "RUB", name: "Russian Ruble" },
            { country: "RW", currencyCode: "RWF", name: "Rwanda Franc" },
            { country: "BL", currencyCode: "EUR", name: "Euro" },
            { country: "SH", currencyCode: "SHP", name: "Saint Helena Pound" },
            { country: "KN", currencyCode: "XCD", name: "East Caribbean Dollar" },
            { country: "LC", currencyCode: "XCD", name: "East Caribbean Dollar" },
            { country: "MF", currencyCode: "EUR", name: "Euro" },
            { country: "PM", currencyCode: "EUR", name: "Euro" },
            { country: "VC", currencyCode: "XCD", name: "East Caribbean Dollar" },
            { country: "WS", currencyCode: "WST", name: "Tala" },
            { country: "SM", currencyCode: "EUR", name: "Euro" },
            { country: "ST", currencyCode: "STN", name: "Dobra" },
            { country: "SA", currencyCode: "SAR", name: "Saudi Riyal" },
            { country: "SN", currencyCode: "XOF", name: "CFA Franc BCEAO" },
            { country: "RS", currencyCode: "RSD", name: "Serbian Dinar" },
            { country: "SC", currencyCode: "SCR", name: "Seychelles Rupee" },
            { country: "SL", currencyCode: "SLL", name: "Leone" },
            { country: "SG", currencyCode: "SGD", name: "Singapore Dollar" },
            { country: "SX", currencyCode: "ANG", name: "Netherlands Antillean Guilder" },
            { country: "SK", currencyCode: "EUR", name: "Euro" },
            { country: "SI", currencyCode: "EUR", name: "Euro" },
            { country: "SB", currencyCode: "SBD", name: "Solomon Islands Dollar" },
            { country: "SO", currencyCode: "SOS", name: "Somali Shilling" },
            { country: "ZA", currencyCode: "ZAR", name: "Rand" },
            { country: "GS", currencyCode: "", name: "No universal currency" },
            { country: "SS", currencyCode: "SSP", name: "South Sudanese Pound" },
            { country: "ES", currencyCode: "EUR", name: "Euro" },
            { country: "LK", currencyCode: "LKR", name: "Sri Lanka Rupee" },
            { country: "SD", currencyCode: "SDG", name: "Sudanese Pound" },
            { country: "SR", currencyCode: "SRD", name: "Surinam Dollar" },
            { country: "SJ", currencyCode: "NOK", name: "Norwegian Krone" },
            //{ country: "EE", currencyCode: "SZL", name: "Lilangeni" },
            { country: "SE", currencyCode: "SEK", name: "Swedish Krona" },
            { country: "CH", currencyCode: "CHF", name: "Swiss Franc" },
            { country: "CH", currencyCode: "CHE", name: "WIR Euro" },
            { country: "CH", currencyCode: "CHW", name: "WIR Franc" },
            { country: "SY", currencyCode: "SYP", name: "Syrian Pound" },
            { country: "TW", currencyCode: "TWD", name: "New Taiwan Dollar" },
            { country: "TJ", currencyCode: "TJS", name: "Somoni" },
            { country: "TZ", currencyCode: "TZS", name: "Tanzanian Shilling" },
            { country: "TH", currencyCode: "THB", name: "Baht" },
            { country: "TL", currencyCode: "USD", name: "US Dollar" },
            { country: "TG", currencyCode: "XOF", name: "CFA Franc BCEAO" },
            { country: "TK", currencyCode: "NZD", name: "New Zealand Dollar" },
            { country: "TO", currencyCode: "TOP", name: "Pa’anga" },
            { country: "TT", currencyCode: "TTD", name: "Trinidad and Tobago Dollar" },
            { country: "TN", currencyCode: "TND", name: "Tunisian Dinar" },
            { country: "TR", currencyCode: "TRY", name: "Turkish Lira" },
            { country: "TM", currencyCode: "TMT", name: "Turkmenistan New Manat" },
            { country: "TC", currencyCode: "USD", name: "US Dollar" },
            { country: "TV", currencyCode: "AUD", name: "Australian Dollar" },
            { country: "UG", currencyCode: "UGX", name: "Uganda Shilling" },
            { country: "UA", currencyCode: "UAH", name: "Hryvnia" },
            { country: "AE", currencyCode: "AED", name: "UAE Dirham" },
            { country: "GB", currencyCode: "GBP", name: "Pound Sterling" },
            { country: "UM", currencyCode: "USD", name: "US Dollar" },
            { country: "US", currencyCode: "USD", name: "US Dollar" },
            { country: "US", currencyCode: "USN", name: "US Dollar (Next day)" },
            { country: "UY", currencyCode: "UYU", name: "Peso Uruguayo" },
            { country: "UY", currencyCode: "UYI", name: "Uruguay Peso en Unidades Indexadas (UI)" },
            { country: "UY", currencyCode: "UYW", name: "Unidad Previsional" },
            { country: "UZ", currencyCode: "UZS", name: "Uzbekistan Sum" },
            { country: "VU", currencyCode: "VUV", name: "Vatu" },
            { country: "VE", currencyCode: "VES", name: "Bolívar Soberano" },
            { country: "VN", currencyCode: "VND", name: "Dong" },
            //{ country: "VI", currencyCode: "USD", name: "US Dollar" },
            //{ country: "VI", currencyCode: "USD", name: "US Dollar" },
            { country: "WF", currencyCode: "XPF", name: "CFP Franc" },
            { country: "EH", currencyCode: "MAD", name: "Moroccan Dirham" },
            { country: "YE", currencyCode: "YER", name: "Yemeni Rial" },
            { country: "ZM", currencyCode: "ZMW", name: "Zambian Kwacha" },
            { country: "ZW", currencyCode: "ZWL", name: "Zimbabwe Dollar" },
            { country: "XU", currencyCode: "XUA", name: "ADB Unit of Account" },
        ];
        
        const currencySet = currencies.filter(x => x.country == country);
        component.set("v.stateOptions", states.filter(x => x.country == country));
        
        if (currencySet.length == 1) {
        	component.set("v.currencyOptions", 
            	[Object.assign({}, currencySet[0], { selected: true })])
                
            component.set("v.selectedCurrencyValue", currencySet[0].currencyCode);
        }
    	else
            component.set("v.currencyOptions", currencySet);
            
        component.find("proposal-form")[1].showHelpMessageIfInvalid();
    },
    handleCustomerLookup: function(component, event, helper) {
        const valueCallback = event.getParam("return");
        if (valueCallback != null)
        	component.set('v.serviceTagsInput', valueCallback);
    },
    addAsset: function(component, event, helper) {
        var list = component.get('v.assetInputList');
        list.push({ brand: "", productType: "", baseUnit: "", processor: "", quantity: "1", baseUnitOptions: [], processorOptions: [] });

        component.set('v.assetInputList', list);
    },
    removeAsset: function(component, event, helper) {
        var index = event.getSource().get("v.name");
        var list = component.get('v.assetInputList');
        
        list.splice(index, 1);
        component.set('v.assetInputList', list);
    },
    questionsInputChange: function(component, event, helper) {
        var index = event.getSource().get("v.name").split('-')[1];
        var item = component.get('v.assetInputList')[index];
        
        if (item.processor != "" || item.baseUnit != ""){
            item.processor = "";
            item.baseUnit = "";
            
            var list = component.get('v.assetInputList');
            list[index] = item;
            component.set('v.assetInputList', list);
        }
        
        if (item.brand != "" && item.productType !=  ""){
            helper.showLoadingSpinner(true);
            
            var partsAction = component.get("c.getBaseUnits");
            partsAction.setParams({"queryString": "&brand=" + item.brand + "&productType=" + item.productType });
            partsAction.setCallback(this, function(response, component){
                if (response.getState() === "SUCCESS") {
                    try {
                        var result = response.getReturnValue();
                        
                        if (result.Status != 200) {
                            helper.showErrorMessage(component, null, helper.formatErrorMessageType(result.Body));
                        } else
                        {
                            var parsedResult = JSON.parse(result.Body);
                            item.baseUnitOptions = parsedResult;
                            
                            var list = component.get('v.assetInputList');
                            list[index] = item;
                            component.set('v.assetInputList', list);
                        }
                    }
                    catch (e) {
                        helper.showErrorMessage(component, null);
                    }
                    finally {
                        helper.showLoadingSpinner(false);
                    }
                } else {
                    var errors = response.getError();
                    
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    }
                    
                    helper.showErrorMessage(component);
                    helper.showLoadingSpinner(false);
                }
            });
            
            $A.enqueueAction(partsAction);
        }   
    },
    
    openActionWindow : function(component, event, helper) {
        window.open(component.get("v.redirectUrl"), '_blank');
    },
    
    makeRequest: function(component, event, helper) {
        var validForm = component.find('proposal-form').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        if (validForm){  
            helper.showLoadingSpinner(true);
            
            const tags = component.get("v.serviceTagsInput");
            const countryCode = component.get("v.countryInput");
            const stateCode = component.get("v.stateInput");
            const currencyCode = component.get("v.selectedCurrencyValue");
            const title = component.get("v.titleInput");
            const list = component.get('v.assetInputList') || [];
            const account = component.get('v.account');
            const customerNumber = component.get("v.customerNumberInput");
            
            const parsedTags = tags != null && tags != ""? 
                tags.split(new RegExp('[- ;,/\n]{1,}', 'g')).map(s => s.trim()) : [];
            
            let assets = [];
            parsedTags.forEach(x => assets.push({ serviceTag: x, quantity: 1, partNumbers: [] }));
            list.forEach(x => assets.push({ serviceTag: "", quantity: x.quantity, partNumbers: [x.processor, x.baseUnit]} ));
            
            const body = {
                "assets": assets,
                "country" : countryCode,
                "state": stateCode,
                "currency": currencyCode,
                "CustomerNumber": account.AccountNumber,
                "title": title,
                "BuID" : account.BUID__c
            }; 
            
            var action = component.get("c.newVrp");
            action.setParams({"body": JSON.stringify(body)});
            action.setCallback(this, function(response, component){
                if (response.getState() === "SUCCESS") {
                    try {
                        var result = response.getReturnValue();
                        
                        if (result.Status != 200) {
                            helper.showErrorMessage(component, null, helper.formatErrorMessageType(result.Body));
                            component.set("v.proposalResponse", null);
                            component.set("v.redirectUrl", null);
                        } else {
                            const parsedResponse = JSON.parse(result.Body);
                            component.set("v.proposalResponse", parsedResponse); 
                            
                            var queryAction = component.get("c.getInternalId");
                            queryAction.setParams({"requestId": parsedResponse.proposalID});
                            queryAction.setCallback(this, function(response, component){
                                component.set("v.redirectUrl", "/lightning/r/Proposal__x/" + response.getReturnValue() + "/view");
                            });
                            
                            $A.enqueueAction(queryAction);
                        }
                    }
                    catch (e) {
                        helper.showErrorMessage(component, null);
                        component.set("v.proposalResponse", null);
                        component.set("v.redirectUrl", null);
                    }
                    finally {
                        helper.showLoadingSpinner(false);
                    }
                } else {
                    let errors = response.getError();
                    
                    if (errors && errors[0] && errors[0].message) {
                    	console.log("Error message: " + errors[0].message);
                    }
                    
                    helper.showErrorMessage(component);
                    component.set("v.response", null); 
                    helper.showLoadingSpinner(false);
                }
            });
            
            $A.enqueueAction(action);
        }
    }
})