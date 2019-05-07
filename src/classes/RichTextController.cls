public class RichTextController {

    private static final Pattern URL_REGEX = Pattern.compile('src="(.+?)"');
    private static final Pattern ME_REGEX = Pattern.compile('src="@ME:(.+?)@"');

    // From ExternalIds To URLs
    
    @AuraEnabled
    public static String replaceExternalIdsWithURLs(String richText){
        List<String> mes = getBodyMEs(richText);
        Map<String, String> externalIdURLMap = getExternalIdURLMap(mes);
        return replaceExternalIdsWithURLs(richText, externalIdURLMap, mes);
    }


    public static String replaceExternalIdsWithURLs(String richText, Map<String, String> externalIdUrlMap, List<String> totalExtIds){
        Set<String> extIdSet = new Set<String>(totalExtIds);
        for(String extId : extIdSet){
            if(externalIdUrlMap.containsKey(extId)){
                richText = richText.replace('src="@ME:' + extId + '@"', 'src="' + externalIdUrlMap.get(extId) + '"');
            } else {
                richText = richText.replace('src="@ME:' + extId + '@"', 'src=""');
            }
        }
        return richText;
    }

    public static Map<String, String> getExternalIdURLMap(List<String> mediaElementExternalIds){
        Map<String, String> mapToReturn = new Map<String, String>();
        List<MediaElement__c> mediaElements = [SELECT Id, ExternalId__c, FileURLDesktop__c FROM MediaElement__c WHERE ExternalId__c IN: mediaElementExternalIds];
        for(MediaElement__c mediaElement : mediaElements){
            mapToReturn.put(mediaElement.ExternalId__c, mediaElement.FileURLDesktop__c);
        }

        return mapToReturn;
    }
    
    private static List<String> getBodyMEs(String body) {
        final List<String> mes = new List<String>();
        final Matcher matcher = ME_REGEX.matcher(body);
        while (matcher.find()) {
            mes.add(matcher.group(1));
        }
        return mes;
    }

    // From URLs To ExternalIds

    @AuraEnabled
    public static String replaceURLsWithExternalIds(String richText){
        List<String> bodyURLs = getBodyURLs(richText);
        Map<String, String> urlExternalIdMap = getURLExternalIdMap(bodyURLs);
        return replaceURLsWithExternalIds(richText, urlExternalIdMap);
    }

    public static String replaceURLsWithExternalIds(String richText, Map<String, String> urlExternalIdMap){
        for(String url : urlExternalIdMap.keySet()){
            richText = richText.replace('src="' + url + '"', 'src="@ME:' + urlExternalIdMap.get(url) + '@"');
            richText = richText.replace('src="' + url.replace('&','&amp;') + '"', 'src="@ME:' + urlExternalIdMap.get(url) + '@"');
        }
        System.debug('[RichTextController][replaceURLsWithExternalIds] richText: ' + richText);
        return richText;
    }

    public static Map<String, String> getURLExternalIdMap(List<String> mediaElementURLs){
        Map<String, String> mapToReturn = new Map<String, String>();
        List<MediaElement__c> mediaElements = [SELECT Id, ExternalId__c, FileURLDesktop__c FROM MediaElement__c WHERE FileURLDesktop__c IN: mediaElementURLs];
        for(MediaElement__c mediaElement : mediaElements){
            mapToReturn.put(mediaElement.FileURLDesktop__c, mediaElement.ExternalId__c);
        }

        return mapToReturn;
    }

    private static List<String> getBodyURLs(String body) {
        final List<String> urls = new List<String>();
        final Matcher matcher = URL_REGEX.matcher(body);
        while (matcher.find()) {
            urls.add(matcher.group(1).replace('&amp;','&'));
        }
        return urls;
    }
}