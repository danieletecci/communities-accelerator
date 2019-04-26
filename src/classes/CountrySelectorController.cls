public with sharing class CountrySelectorController {
	//WRAPPER

	public class CountrySelectedWrapper {
		@auraEnabled public String name;
		@auraEnabled public String iso;
		@auraEnabled public String phoneCode;

		public CountrySelectedWrapper(String name, String iso, String phoneCode){
			this.name = name;
			this.iso = iso;
			this.phoneCode = phoneCode;
		}	
	}

	public class CountriesWrapper {
		@auraEnabled public CountrySelectedWrapper selected;
		@auraEnabled public List<Map<String,String>> countriesList;

		public CountriesWrapper(CountrySelectedWrapper selected, List<Map<String,String>> countriesList){
			this.selected = selected;
			this.countriesList = countriesList;
		}	
	}

	@AuraEnabled
    public static CountriesWrapper getCountriesCodes(){

    	String userCountry = UserInfo.getLocale().right(2);
	
    	String stringJSON= '[{ "name" : "Afghanistan", "iso" : "af", "phoneCode" : "+93"},' +
    	' {"name" : "Albania",							"iso" : "al", "phoneCode" : "+355" },'+
    	' {"name" : "Algeria",							"iso" : "dz", "phoneCode" : "+213" },'+
  		' {"name" : "Andorra",							"iso" : "ad", "phoneCode" : "+376" },'+
  		' {"name" : "Angola",							"iso" : "ao", "phoneCode" : "+244" },'+
  		' {"name" : "Antigua and Barbuda",				"iso" : "ag", "phoneCode" : "+1268"},'+
  		' {"name" : "Argentina",						"iso" : "ar", "phoneCode" : "+54"  },'+
  		' {"name" : "Armenia",							"iso" : "am", "phoneCode" : "+374" },'+
  		' {"name" : "Australia",						"iso" : "au", "phoneCode" : "+61"  },'+
  		' {"name" : "Austria",							"iso" : "at", "phoneCode" : "+43"  },'+
  		' {"name" : "Azerbaijan",						"iso" : "az", "phoneCode" : "+994" },'+
  		' {"name" : "Bahamas",							"iso" : "bs", "phoneCode" : "+1242"},'+
  		' {"name" : "Bahrain",							"iso" : "bh", "phoneCode" : "+973" },'+
  		' {"name" : "Bangladesh",						"iso" : "bd", "phoneCode" : "+880" },'+
  		' {"name" : "Barbados",							"iso" : "bb", "phoneCode" : "+1246"},'+
  		' {"name" : "Belarus",							"iso" : "by", "phoneCode" : "+375" },'+
  		' {"name" : "Belgium",							"iso" : "be", "phoneCode" : "+32"  },'+
  		' {"name" : "Belize",							"iso" : "bz", "phoneCode" : "+501" },'+
  		' {"name" : "Benin",							"iso" : "bj", "phoneCode" : "+229" },'+
  		' {"name" : "Bhutan",							"iso" : "bt", "phoneCode" : "+975" },'+
  		' {"name" : "Bolivia",							"iso" : "bo", "phoneCode" : "+591" },'+
  		' {"name" : "Bosnia and Herzegovina",			"iso" : "ba", "phoneCode" : "+387" },'+
  		' {"name" : "Botswana",							"iso" : "bw", "phoneCode" : "+267" },'+
  		' {"name" : "Brazil",							"iso" : "br", "phoneCode" : "+55"  },'+
  		' {"name" : "Brunei",							"iso" : "bn", "phoneCode" : "+673" },'+
  		' {"name" : "Bulgaria",							"iso" : "bg", "phoneCode" : "+359" },'+
  		' {"name" : "Burkina Faso",						"iso" : "bf", "phoneCode" : "+226" },'+
  		' {"name" : "Burundi",							"iso" : "bi", "phoneCode" : "+257" },'+
  		' {"name" : "Cambodia",							"iso" : "kh", "phoneCode" : "+855" },'+
  		' {"name" : "Cameroon",							"iso" : "cm", "phoneCode" : "+237" },'+
  		' {"name" : "Canada",							"iso" : "ca", "phoneCode" : "+1"   },'+
  		' {"name" : "Cape Verde",						"iso" : "cv", "phoneCode" : "+238" },'+
  		' {"name" : "Central African Republic",			"iso" : "cf", "phoneCode" : "+236" },'+
  		' {"name" : "Chad",								"iso" : "td", "phoneCode" : "+235" },'+
  		' {"name" : "Chile",							"iso" : "cl", "phoneCode" : "+56"  },'+
  		' {"name" : "China",							"iso" : "cn", "phoneCode" : "+86"  },'+
  		' {"name" : "Colombia",							"iso" : "co", "phoneCode" : "+57"  },'+
  		' {"name" : "Comoros",							"iso" : "km", "phoneCode" : "+269" },'+
  		' {"name" : "Congo",							"iso" : "cd", "phoneCode" : "+243" },'+
  		' {"name" : "Congo",							"iso" : "cg", "phoneCode" : "+242" },'+
  		' {"name" : "Costa Rica",						"iso" : "cr", "phoneCode" : "+506" },'+
  		' {"name" : "Cote d Ivoire",					"iso" : "ci", "phoneCode" : "+225" },'+
  		' {"name" : "Croatia",							"iso" : "hr", "phoneCode" : "+385" },'+
  		' {"name" : "Cuba",								"iso" : "cu", "phoneCode" : "+53"  },'+
  		' {"name" : "Cyprus",							"iso" : "cy", "phoneCode" : "+357" },'+
  		' {"name" : "Czech Republic",					"iso" : "cz", "phoneCode" : "+420" },'+
  		' {"name" : "Denmark",							"iso" : "dk", "phoneCode" : "+45"  },'+
  		' {"name" : "Djibouti",							"iso" : "dj", "phoneCode" : "+253" },'+
  		' {"name" : "Dominica",							"iso" : "dm", "phoneCode" : "+1767"},'+
  		' {"name" : "Dominican Republic",               "iso" : "do", "phoneCode" : "+1"   },'+
  		' {"name" : "Ecuador",							"iso" : "ec", "phoneCode" : "+593" },'+
  		' {"name" : "Egypt",							"iso" : "eg", "phoneCode" : "+20"  },'+
  		' {"name" : "El Salvador",						"iso" : "sv", "phoneCode" : "+503" },'+
  		' {"name" : "Equatorial Guinea",				"iso" : "gq", "phoneCode" : "+240" },'+ 
  		' {"name" : "Eritrea",							"iso" : "er", "phoneCode" : "+291" },'+
  		' {"name" : "Estonia",							"iso" : "ee", "phoneCode" : "+372" },'+
  		' {"name" : "Ethiopia",							"iso" : "et", "phoneCode" : "+251" },'+
  		' {"name" : "Fiji",								"iso" : "fj", "phoneCode" : "+679" },'+
  		' {"name" : "Finland",							"iso" : "fi", "phoneCode" : "+358" },'+
  		' {"name" : "France",							"iso" : "fr", "phoneCode" : "+33"  },'+
  		' {"name" : "Gabon",							"iso" : "ga", "phoneCode" : "+241" },'+
  		' {"name" : "Gambia",							"iso" : "gm", "phoneCode" : "+220" },'+
  		' {"name" : "Georgia",							"iso" : "ge", "phoneCode" : "+995" },'+
  		' {"name" : "Germany",							"iso" : "de", "phoneCode" : "+49"  },'+
  		' {"name" : "Ghana",							"iso" : "gh", "phoneCode" : "+233" },'+
  		' {"name" : "Greece",							"iso" : "gr", "phoneCode" : "+30"  },'+
  		' {"name" : "Grenada",							"iso" : "gd", "phoneCode" : "+1473"},'+
  		' {"name" : "Guatemala",						"iso" : "gt", "phoneCode" : "+502" },'+
  		' {"name" : "Guinea",							"iso" : "gn", "phoneCode" : "+224" },'+
  		' {"name" : "Guinea-Bissau",					"iso" : "gw", "phoneCode" : "+245" },'+
  		' {"name" : "Guyana",							"iso" : "gy", "phoneCode" : "+592" },'+
  		' {"name" : "Haiti",							"iso" : "ht", "phoneCode" : "+509" },'+
  		' {"name" : "Honduras",							"iso" : "hn", "phoneCode" : "+504" },'+
  		' {"name" : "Hungary",							"iso" : "hu", "phoneCode" : "+36"  },'+
  		' {"name" : "Iceland",							"iso" : "is", "phoneCode" : "+354" },'+
  		' {"name" : "India",							"iso" : "in", "phoneCode" : "+91"  },'+
  		' {"name" : "Indonesia",						"iso" : "id", "phoneCode" : "+62"  },'+
  		' {"name" : "Iran",								"iso" : "ir", "phoneCode" : "+98"  },'+
  		' {"name" : "Iraq",								"iso" : "iq", "phoneCode" : "+964" },'+
		' {"name" : "Ireland", "iso" : "ie", "phoneCode" : "+353" },'+
		' {"name" : "Israel", "iso" : "il", "phoneCode" : "+972" },'+
		' {"name" : "Italy", "iso" : "it", "phoneCode" : "+39" },'+
		' {"name" : "Jamaica", "iso" : "jm", "phoneCode" : "+1" },'+
		' {"name" : "Japan", "iso" : "jp", "phoneCode" : "+81" },'+
		' {"name" : "Jordan", "iso" : "jo", "phoneCode" : "+962" },'+
		' {"name" : "Kazakhstan", "iso" : "kz", "phoneCode" : "+7" },'+
		' {"name" : "Kenya", "iso" : "ke", "phoneCode" : "+254" },'+
		' {"name" : "Kiribati", "iso" : "ki", "phoneCode" : "+686" },'+
		' {"name" : "Kuwait", "iso" : "kw", "phoneCode" : "+965" },'+
		' {"name" : "Kyrgyzstan", "iso" : "kg", "phoneCode" : "+996" },'+
		' {"name" : "Laos", "iso" : "la", "phoneCode" : "+856" },'+
		' {"name" : "Latvia", "iso" : "lv", "phoneCode" : "+371" },'+
		' {"name" : "Lebanon", "iso" : "lb", "phoneCode" : "+961" },'+
		' {"name" : "Lesotho", "iso" : "ls", "phoneCode" : "+266" },'+
		' {"name" : "Liberia", "iso" : "lr", "phoneCode" : "+231" },'+
		' {"name" : "Libya", "iso" : "ly", "phoneCode" : "+218" },'+
		' {"name" : "Liechtenstein", "iso" : "li", "phoneCode" : "+423" },'+
		' {"name" : "Lithuania", "iso" : "lt", "phoneCode" : "+370" },'+
		' {"name" : "Luxembourg", "iso" : "lu", "phoneCode" : "+352" },'+
		' {"name" : "Macedonia", "iso" : "mk", "phoneCode" : "+389" },'+
		' {"name" : "Madagascar", "iso" : "mg", "phoneCode" : "+261" },'+
		' {"name" : "Malawi", "iso" : "mw", "phoneCode" : "+265" },'+
		' {"name" : "Malaysia", "iso" : "my", "phoneCode" : "+60" },'+
		' {"name" : "Maldives", "iso" : "mv", "phoneCode" : "+960" },'+
		' {"name" : "Mali", "iso" : "ml", "phoneCode" : "+223" },'+
		' {"name" : "Malta", "iso" : "mt", "phoneCode" : "+356" },'+
		' {"name" : "Marshall Islands", "iso" : "mh", "phoneCode" : "+692" },'+
		' {"name" : "Mauritania", "iso" : "mr", "phoneCode" : "+222" },'+
		' {"name" : "Mauritius", "iso" : "mu", "phoneCode" : "+230" },'+
		' {"name" : "Mexico", "iso" : "mx", "phoneCode" : "+52" },'+
		' {"name" : "Micronesia", "iso" : "fm", "phoneCode" : "+691" },'+
		' {"name" : "Moldova", "iso" : "md", "phoneCode" : "+373" },'+
		' {"name" : "Monaco", "iso" : "mc", "phoneCode" : "+377" },'+
		' {"name" : "Mongolia", "iso" : "mn", "phoneCode" : "+976" },'+
		' {"name" : "Montenegro", "iso" : "me", "phoneCode" : "+382" },'+
		' {"name" : "Morocco", "iso" : "ma", "phoneCode" : "+212" },'+
		' {"name" : "Mozambique", "iso" : "mz", "phoneCode" : "+258" },'+
		' {"name" : "Myanmar", "iso" : "mm", "phoneCode" : "+95" },'+
		' {"name" : "Namibia", "iso" : "na", "phoneCode" : "+264" },'+
		' {"name" : "Nauru", "iso" : "nr", "phoneCode" : "+674" },'+
		' {"name" : "Nepal", "iso" : "np", "phoneCode" : "+977" },'+
		' {"name" : "Netherlands", "iso" : "nl", "phoneCode" : "+31" },'+
		' {"name" : "New Zealand", "iso" : "nz", "phoneCode" : "+64" },'+
		' {"name" : "Nicaragua", "iso" : "ni", "phoneCode" : "+505" },'+
		' {"name" : "Niger", "iso" : "ne", "phoneCode" : "+227" },'+
		' {"name" : "Nigeria", "iso" : "ng", "phoneCode" : "+234" },'+
		' {"name" : "North Korea", "iso" : "kp", "phoneCode" : "+850" },'+
		' {"name" : "Norway", "iso" : "no", "phoneCode" : "+47" },'+
		' {"name" : "Oman", "iso" : "om", "phoneCode" : "+968" },'+
		' {"name" : "Pakistan", "iso" : "pk", "phoneCode" : "+92" },'+
		' {"name" : "Palau", "iso" : "pw", "phoneCode" : "+680" },'+
		' {"name" : "Panama", "iso" : "pa", "phoneCode" : "+507" },'+
		' {"name" : "Papua New Guinea", "iso" : "pg", "phoneCode" : "+675" },'+
		' {"name" : "Paraguay", "iso" : "py", "phoneCode" : "+595" },'+
		' {"name" : "Peru", "iso" : "pe", "phoneCode" : "+51" },'+
		' {"name" : "Philippines", "iso" : "ph", "phoneCode" : "+63" },'+
		' {"name" : "Poland", "iso" : "pl", "phoneCode" : "+48" },'+
		' {"name" : "Portugal", "iso" : "pt", "phoneCode" : "+351" },'+
		' {"name" : "Qatar", "iso" : "qa", "phoneCode" : "+974" },'+
		' {"name" : "Romania", "iso" : "ro", "phoneCode" : "+40" },'+
		' {"name" : "Russia", "iso" : "ru", "phoneCode" : "+7" },'+
		' {"name" : "Rwanda", "iso" : "rw", "phoneCode" : "+250" },'+
		' {"name" : "Saint Kitts and Nevis", "iso" : "kn", "phoneCode" : "+1869" },'+
		' {"name" : "Saint Lucia", "iso" : "lc", "phoneCode" : "+1758" },'+
		' {"name" : "Saint Vincent and the Grenadines", "iso" : "vc", "phoneCode" : "+1784" },'+
		' {"name" : "Samoa", "iso" : "ws", "phoneCode" : "+685" },'+
		' {"name" : "San Marino", "iso" : "sm", "phoneCode" : "+378" },'+
		' {"name" : "São Tomé and Príncipe", "iso" : "st", "phoneCode" : "+239" },'+
		' {"name" : "Saudi Arabia", "iso" : "sa", "phoneCode" : "+966" },'+
		' {"name" : "Senegal", "iso" : "sn", "phoneCode" : "+221" },'+
		' {"name" : "Serbia", "iso" : "rs", "phoneCode" : "+381" },'+
		' {"name" : "Seychelles", "iso" : "sc", "phoneCode" : "+248" },'+
		' {"name" : "Sierra Leone", "iso" : "sl", "phoneCode" : "+232" },'+
		' {"name" : "Singapore", "iso" : "sg", "phoneCode" : "+65" },'+
		' {"name" : "Slovakia", "iso" : "sk", "phoneCode" : "+421" },'+
		' {"name" : "Slovenia", "iso" : "si", "phoneCode" : "+386" },'+
		' {"name" : "Solomon Islands", "iso" : "sb", "phoneCode" : "+677" },'+
		' {"name" : "Somalia", "iso" : "so", "phoneCode" : "+252" },'+
		' {"name" : "South Africa", "iso" : "za", "phoneCode" : "+27" },'+
		' {"name" : "South Korea", "iso" : "kr", "phoneCode" : "+82" },'+
		' {"name" : "Spain", "iso" : "es", "phoneCode" : "+34" },'+
		' {"name" : "Sri Lanka", "iso" : "lk", "phoneCode" : "+94" },'+
		' {"name" : "Sudan", "iso" : "sd", "phoneCode" : "+249" },'+
		' {"name" : "Suriname", "iso" : "sr", "phoneCode" : "+597" },'+
		' {"name" : "Swaziland", "iso" : "sz", "phoneCode" : "+268" },'+
		' {"name" : "Sweden", "iso" : "se", "phoneCode" : "+46" },'+
		' {"name" : "Switzerland", "iso" : "ch", "phoneCode" : "+41" },'+
		' {"name" : "Syria", "iso" : "sy", "phoneCode" : "+963" },'+
		' {"name" : "Taiwan", "iso" : "tw", "phoneCode" : "+886" },'+
		' {"name" : "Tajikistan", "iso" : "tj", "phoneCode" : "+992" },'+
		' {"name" : "Tanzania", "iso" : "tz", "phoneCode" : "+255" },'+
		' {"name" : "Thailand", "iso" : "th", "phoneCode" : "+66" },'+
		' {"name" : "Timor-Leste", "iso" : "tl", "phoneCode" : "+670" },'+
		' {"name" : "Togo", "iso" : "tg", "phoneCode" : "+228" },'+
		' {"name" : "Tonga", "iso" : "to", "phoneCode" : "+676" },'+
		' {"name" : "Trinidad and Tobago", "iso" : "tt", "phoneCode" : "+1868" },'+
		' {"name" : "Tunisia", "iso" : "tn", "phoneCode" : "+216" },'+
		' {"name" : "Turkey", "iso" : "tr", "phoneCode" : "+90" },'+
		' {"name" : "Turkmenistan", "iso" : "tm", "phoneCode" : "+993" },'+
		' {"name" : "Tuvalu", "iso" : "tv", "phoneCode" : "+688" },'+
		' {"name" : "Uganda", "iso" : "ug", "phoneCode" : "+256" },'+
		' {"name" : "Ukraine", "iso" : "ua", "phoneCode" : "+380" },'+
		' {"name" : "United Arab Emirates", "iso" : "ae", "phoneCode" : "+971" },'+
		' {"name" : "United Kingdom", "iso" : "gb", "phoneCode" : "+44" },'+
		' {"name" : "United States", "iso" : "us", "phoneCode" : "+1" },'+
		' {"name" : "Uruguay", "iso" : "uy", "phoneCode" : "+598" },'+
		' {"name" : "Uzbekistan", "iso" : "uz", "phoneCode" : "+998" },'+
		' {"name" : "Vanuatu", "iso" : "vu", "phoneCode" : "+678" },'+
		' {"name" : "Vatican City", "iso" : "va", "phoneCode" : "+39" },'+
		' {"name" : "Venezuela", "iso" : "ve", "phoneCode" : "+58" },'+
		' {"name" : "Vietnam", "iso" : "vn", "phoneCode" : "+84" },'+
		' {"name" : "Western Sahara", "iso" : "eh", "phoneCode" : "+212" },'+
		' {"name" : "Yemen", "iso" : "ye", "phoneCode" : "+967" },'+
		' {"name" : "Zambia", "iso" : "zm", "phoneCode" : "+260" },'+
		' {"name" : "Zimbabwe", "iso" : "zw", "phoneCode" : "+263" }]';

		List<Map<String,String>> codes = (List<Map<String,String>>) JSON.deserialize(stringJSON, List<Map<String,String>>.class);

		CountrySelectedWrapper countrySelected;

		for(Map<String,String> country : codes){
			if(country.get('iso').equalsIgnoreCase(userCountry)){
				countrySelected = new CountrySelectedWrapper(country.get('name'), country.get('iso'), (String)country.get('phoneCode'));
			}
		}
		CountriesWrapper wrap = new CountriesWrapper(countrySelected, codes);
		return wrap;
    }
}