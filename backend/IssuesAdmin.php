<?php


require_once('api/Backend.php');

class IssuesAdmin extends Backend
{
	public function fetch()
	{
		// Обработка действий
		if($this->request->method('post'))
		{
			// Действия с выбранными
			$ids = $this->request->post('check');
			if(is_array($ids))
			switch($this->request->post('action'))
			{
			    case 'disable':
			    {
					$this->issues->update_issue($ids, array('visible'=>0));	      
					break;
			    }
			    case 'enable':
			    {
					$this->issues->update_issue($ids, array('visible'=>1));	      
			        break;
			    }
			    case 'delete':
			    {
				    foreach($ids as $id)
						$this->issues->delete_issue($id);    
			        break;
			    }
			}				
		}

		$filter = array();

		$house_id = $this->request->get('house_id', 'integer');
		if(!empty($house_id))
		{
			$filter['house_id'] = $house_id;
			$this->design->assign('house_id', $house_id);
		}

		$issues = $this->issues->get_issues($filter);


		$houses = $this->pages->get_pages(array('menu_id'=>5, 'not_tree'=>1));
		if(!empty($houses))
			$houses= $this->categories_tree->get_categories_tree('houses', $houses);
		$this->design->assign('houses', $houses);

		$this->design->assign('statuses', array('Not started', 'In progress', 'Done'));


		$this->design->assign('issues', $issues);
		return $this->design->fetch('issues.tpl');
	}
}
