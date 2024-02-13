<?php

session_start();

require_once('../../api/Backend.php');

$backend = new Backend();

// Проверка сессии для защиты от xss
if(!$backend->request->check_session())
{
	trigger_error('Session expired', E_USER_WARNING);
	exit();
}

$id = intval($backend->request->post('id'));
$object = $backend->request->post('object');
$values = $backend->request->post('values');

switch ($object)
{
    case 'product':
    	if($backend->managers->access('products'))
        $result = $backend->products->update_product($id, $values);
        break;
	case 'kits_group':
        $result = $backend->kits->update_kits_group($id, $values);
        break;
	case 'kit':
        $result = $backend->kits->update_kit($id, $values);
        break;
    case 'category':
    	if($backend->managers->access('categories'))
        $result = $backend->categories->update_category($id, $values);
        break;
    case 'brands':
    	if($backend->managers->access('brands'))
        $result = $backend->brands->update_brand($id, $values);
        break;
    case 'feature':
    	if($backend->managers->access('features'))
        $result = $backend->features->update_feature($id, $values);
        break;
    case 'page':
    	if($backend->managers->access('pages'))
        $result = $backend->pages->update_page($id, $values);
        break;
    case 'loan':
        if($backend->managers->access('pages'))
        $result = $backend->loans->update_loan($id, $values);
        break;
    case 'blog_tag':
        if($backend->managers->access('blog'))
        $result = $backend->blog->update_tag($id, $values);
        break;
    case 'author':
        if($backend->managers->access('blog'))
        $result = $backend->blog->update_author($id, $values);
        break;
    case 'blog':
    	if($backend->managers->access('blog'))
        $result = $backend->blog->update_post($id, $values);
        break;
    case 'post':
        if($backend->managers->access('blog'))
        $result = $backend->blog->update_post($id, $values);
        break;
	case 'category_galleries':
    	if($backend->managers->access('galleries'))
        $result = $backend->galleries->update_category($id, $values);
        break;
	case 'gallery':
    	if($backend->managers->access('galleries'))
        $result = $backend->galleries->update_gallery($id, $values);
        break;
	case 'image':
    	if($backend->managers->access('galleries'))
        $result = $backend->galleries->update_image($id, $values);
        break;
    case 'delivery':
    	if($backend->managers->access('delivery'))
        $result = $backend->delivery->update_delivery($id, $values);
        break;
    case 'payment':
    	if($backend->managers->access('payment'))
        $result = $backend->payment->update_payment_method($id, $values);
        break;
    case 'currency':
    	if($backend->managers->access('currency'))
        $result = $backend->money->update_currency($id, $values);
        break;
    case 'comment':
    	if($backend->managers->access('comments'))
        $result = $backend->comments->update_comment($id, $values);
        break;
    case 'user':
    	if($backend->managers->access('users'))
        $result = $backend->users->update_user($id, $values);
        break;
    case 'label':
    	if($backend->managers->access('labels'))
        $result = $backend->orders->update_label($id, $values);
        break;
    case 'issue':
        if($backend->managers->access('issues'))
        $result = $backend->issues->update_issue($id, $values);
        break;
    case 'inventories_group':
        if($backend->managers->access('inventories'))
        $result = $backend->inventories->update_group($id, $values);
        break;
    case 'inventories_item':
        if($backend->managers->access('inventories'))
        $result = $backend->inventories->update_item($id, $values);
        break;

    
}

header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");		
$json = json_encode($result);
print $json;