<?PHP 

require_once('api/Backend.php');

########################################
class LoansAdmin extends Backend
{

  public function fetch()
  {
  	// Меню
    $menus = $this->pages->get_menus();
 	$this->design->assign('menus', $menus);



  	$filter = array();
  	if($this->request->get('type', 'integer'))
  	{
  		$filter['type'] = $this->request->get('type', 'integer');
  		$this->design->assign('type', $filter['type']);
  	}

  	
  


   	// Обработка действий
  	if($this->request->method('post'))
  	{
		// Сортировка
		$positions = $this->request->post('positions'); 		
 		$ids = array_keys($positions);
		sort($positions);
		foreach($positions as $i=>$position)
			$this->loans->update_loan($ids[$i], array('position'=>$position)); 

		
		// Действия с выбранными
		$ids = $this->request->post('check');
		if(is_array($ids))
		switch($this->request->post('action'))
		{
		    case 'disable':
		    {
				$this->loans->update_loan($ids, array('visible'=>0));	      
				break;
		    }
		    case 'enable':
		    {
				$this->loans->update_loan($ids, array('visible'=>1));	      
		        break;
		    }
		    case 'delete':
		    {
			    foreach($ids as $id)
					$this->loans->delete_loan($id);    
		        break;
		    }
		}		
		
 	}

	// Отображение
  	$loans = $this->loans->get_loans($filter);
  	//print_r($loans); exit;
 	$this->design->assign('loans', $loans);
	return $this->design->fetch('loans.tpl');
  }
}


?>