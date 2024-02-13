<?php


require_once('View.php');

class TechnicalIssuesView extends View
{
	public function fetch()
	{
		if(empty($this->user))
		{
			header('Location: '.$this->config->root_url.'/user/login');
			exit();
		}
		

		$filter = array();
		if(!empty($this->user->house_id))
			$filter['house_id'] = $this->user->house_id;
		$filter['visible'] = 1;

		$issues = $this->issues->get_issues($filter);

		if(empty($this->user->house_id))
		{
			$rooms_ = $this->pages->get_pages(array('menu_id'=>5, 'visible'=>1));
			if(!empty($rooms_))
			{
				$rooms = array();
				foreach($rooms_ as $r)
					$rooms[$r->id] = $r;
				unset($rooms_);

				$this->design->assign('rooms', $rooms);
			}
		}

		$this->design->assign('issues_statuses', array('Not started', 'In progress', 'Done'));


		$this->design->assign('issues', $issues);
		return $this->design->fetch('technical_issues.tpl');
	}
}
