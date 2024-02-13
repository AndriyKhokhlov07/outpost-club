<?
chdir('..');
require_once('api/Backend.php');
$backend = new Backend();

$house_id = $backend->request->post('house_id', 'integer');

$results = array();

// Kitchen
// $items = $backend->inventories->get_items(array('house_id'=>$house_id, 'type'=>2, 'visible'=>1));


$items = $backend->inventories->get_items(array('house_id'=>$house_id, 'group_by'=>'i.id', 'visible'=>1));

if(!empty($items))
{
	foreach($items as $item)
	{
		$i = new stdClass;
		$i->id = $item->id;
		$i->name = $item->name;
		$results[] = $i;
	}
}

	
header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");
echo json_encode($results);
