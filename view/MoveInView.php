<?php


require_once('View.php');

class MoveInView extends View
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
			$filter['id'] = $this->user->house_id;
		$filter['visible'] = 1;

		$move_in_pages = $this->pages->get_pages($filter);

		$move_in = current($move_in_pages);

		$this->design->assign('move_in', $move_in);
		return $this->design->fetch('move_in.tpl');
	}
}
