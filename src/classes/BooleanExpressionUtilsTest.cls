@isTest
public with sharing  class BooleanExpressionUtilsTest {
    @isTest static void eval_test() {
        System.assert(BooleanExpressionUtils.validateExpression('1 OR (2 AND 3)', new Set<Integer>{1, 2, 3}));
        System.assert(!BooleanExpressionUtils.validateExpression('1 OR (4 AND 3)', new Set<Integer>{1, 2, 3}));
		System.assert(!BooleanExpressionUtils.validateExpression('1 AND 1', new Set<Integer>{1, 2}));

        System.assert(BooleanExpressionUtils.eval('TRUE'));
        System.assert(BooleanExpressionUtils.eval('TRUE OR FALSE'));
        System.assert(BooleanExpressionUtils.eval('TRUE OR TRUE'));
        System.assert(BooleanExpressionUtils.eval('TRUE OR (TRUE AND FALSE)'));
        System.assert(BooleanExpressionUtils.eval('TRUE OR (TRUE AND FALSE AND TRUE OR TRUE)'));
        System.assert(BooleanExpressionUtils.eval('TRUE OR (TRUE AND FALSE AND (TRUE OR FALSE))'));
        System.assert(BooleanExpressionUtils.eval('TRUE OR (TRUE OR (FALSE AND (TRUE OR FALSE)))'));
        System.assert(BooleanExpressionUtils.eval('(FALSE OR ((TRUE OR FALSE) AND (TRUE OR FALSE)))'));
        
        System.assert(!BooleanExpressionUtils.eval('FALSE'));
        System.assert(!BooleanExpressionUtils.eval('TRUE AND FALSE'));
        System.assert(!BooleanExpressionUtils.eval('FALSE AND FALSE'));
        System.assert(!BooleanExpressionUtils.eval('TRUE AND (TRUE AND FALSE)'));
        System.assert(!BooleanExpressionUtils.eval('FALSE AND (TRUE AND FALSE AND TRUE OR TRUE)'));
        System.assert(!BooleanExpressionUtils.eval('TRUE AND (TRUE AND FALSE AND (TRUE OR FALSE))'));
        System.assert(!BooleanExpressionUtils.eval('TRUE AND (TRUE AND (FALSE AND (TRUE OR FALSE)))'));
        System.assert(!BooleanExpressionUtils.eval('(FALSE AND ((TRUE OR FALSE) AND (TRUE OR FALSE)))'));
    }
}