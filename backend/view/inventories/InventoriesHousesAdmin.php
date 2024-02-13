<?PHP

require_once('api/Backend.php');


class InventoriesHousesAdmin extends Backend
{
	function fetch()
	{
		// Houses
		$houses = $this->pages->get_pages(array('menu_id'=>5, 'not_tree'=>1));
		if(!empty($houses))
			$houses= $this->categories_tree->get_categories_tree('houses', $houses);


		$this->design->assign('houses', $houses);
		$this->design->assign('type',   $this->request->get('type', 'integer'));

		return $this->body = $this->design->fetch('inventories/houses.tpl');
	}
}
