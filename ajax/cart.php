<?php
	session_start();
	require_once('../api/Backend.php');
	$backend = new Backend();
	$backend->cart->add_item($backend->request->get('variant', 'integer'), $backend->request->get('kit', 'integer'), $backend->request->get('amount', 'integer'));
	$cart = $backend->cart->get_cart();
	$backend->design->assign('cart', $cart);
	
	$currencies = $backend->money->get_currencies(array('enabled'=>1));
	if(isset($_SESSION['currency_id']))
		$currency = $backend->money->get_currency($_SESSION['currency_id']);
	else
		$currency = reset($currencies);

	$backend->design->assign('currency',	$currency);
	
	$result = $backend->design->fetch('cart_informer.tpl');
	header("Content-type: application/json; charset=UTF-8");
	header("Cache-Control: must-revalidate");
	header("Pragma: no-cache");
	header("Expires: -1");		
	print json_encode($result);
