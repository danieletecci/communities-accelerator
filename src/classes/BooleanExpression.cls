public class BooleanExpression {
    static Map<String, String> logicTypes = new Map<String, String>();
    static Map<String, Map<String, String>> expressionLogic = new Map<String, Map<String, String>>();
    
    /**
    * Validate a boolean expression 
    *  
    */
    public static Boolean validateExpression(String expression, Set<Integer> validNumberSet){
        if(expression == null || expression == '' || validNumberSet == null || validNumberSet.isEmpty()){
            return false;
        }
        expression = expression.deleteWhitespace().toUpperCase().replaceAll('AND', ' AND ').replaceAll('OR', ' OR ');
        Pattern p = Pattern.compile('(\\d+)');
        Matcher m = p.matcher(expression);
        Set<Integer> existNumberSet = new Set<Integer>();

        if(m.find()) {
            do {
                Integer value = Integer.valueOf(m.group());
                if(!validNumberSet.contains(value)){
                        return false;
                    }else{
                        existNumberSet.add(value);
                    }
            } while(m.find());
        }
        expression = expression.replaceAll('\\d', 'TRUE');
        if(expression.replaceAll('TRUE|\\(|\\)|AND|OR| ', '').length() > 0 || !eval(expression) || existNumberSet.size() != validNumberSet.size()){
            return false;
        }
        return true;
    }

    /**
    * Evaluate a boolean expreassion 
    * 
    */
    public static Boolean eval(String expression) {        
        // If expression contains all TRUE or FALSE
        if(expression.containsNone('FALSE')) { return TRUE; }        
        if(expression.containsNone('TRUE')) { return FALSE; }

        fillLogic();
        Integer limite = 0;
        String value = evaluateExpression(expression.toUpperCase(), limite);
        return Boolean.valueOf(value);
    }
    
    /**
    * Evaluate the expression
    * 
    */
    public static String evaluateExpression(String expression, Integer limite) {        
        
            for(String logicType : logicTypes.keySet()) {
                if(limite < 100){
                    if(expression.contains(logicType)) {
                        expression = simplifyExpression(expression, logicTypes.get(logicType), limite);
                    }
                }
                limite++;
            }
        if(limite < 100){    
            if(expression.contains('AND') || expression.contains('OR') || expression.contains('(')) {
                expression = evaluateExpression(expression, limite);
            }
        }else {
            expression = 'FALSE';
        }
        return expression;
    }
    
    /**
     * Simplify the expression
     * 
     */
    public static string simplifyExpression(String expression, String LogicType, Integer limite){
        Map<String, String> Logic = new Map<String, String>(expressionLogic.get(LogicType));
        for(String key : Logic.keySet()) {
            if(limite < 100){
                expression = expression.replace(key, Logic.get(key));
            }
        }        
        
        return expression;
    } 
    
    /**
    * Fill AND and OR Logic
    * 
    */
    public static void fillLogic() {
        Map<String, String> ANDLogic = new Map<String, String>();
        Map<String, String> ORLogic = new Map<String, String>();
        Map<String, String> BRACELogic = new Map<String, String>();
        
        logicTypes.put('AND', 'AND');
        logicTypes.put('OR', 'OR');
        logicTypes.put('(', 'BRACES');
        
        // AND Logic
        ANDLogic.put('TRUE AND TRUE', 'TRUE');
        ANDLogic.put('TRUE AND FALSE', 'FALSE');
        ANDLogic.put('FALSE AND TRUE', 'FALSE');
        ANDLogic.put('FALSE AND FALSE', 'FALSE');
        expressionLogic.put('AND', ANDLogic);
        
        // OR Logic
        ORLogic.put('TRUE OR TRUE', 'TRUE');
        ORLogic.put('TRUE OR FALSE', 'TRUE');
        ORLogic.put('FALSE OR TRUE', 'TRUE');
        ORLogic.put('FALSE OR FALSE', 'FALSE');
        expressionLogic.put('OR', ORLogic);
        
        // Braces Logic
        BRACELogic.put('(TRUE)', 'TRUE');
        BRACELogic.put('(FALSE)', 'FALSE');
        expressionLogic.put('BRACES', BRACELogic);
    }
}