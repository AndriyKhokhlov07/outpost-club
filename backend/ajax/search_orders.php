<?php
	require_once('../../api/Backend.php');
	$backend = new Backend();
	$limit = 100;
	
	$keyword = $backend->request->get('keyword', 'string');
	if($backend->request->get('limit', 'integer'))
		$limit = $backend->request->get('limit', 'integer');
	
	$orders = array_values($backend->orders->get_orders(array('keyword'=>$keyword, 'limit'=>$limit)));
	

	header("Content-type: application/json; charset=UTF-8");
	header("Cache-Control: must-revalidate");
	header("Pragma: no-cache");
	header("Expires: -1");		
	print json_encode($orders);
