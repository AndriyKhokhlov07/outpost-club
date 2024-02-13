<?PHP
require_once('api/Backend.php');

class IssueAdmin extends Backend
{	
	public function fetch()
	{
		$issue = new stdClass;
		if($this->request->method('POST'))
		{
			$issue->id = $this->request->post('id', 'integer');
			$issue->house_id = $this->request->post('house_id', 'integer');
			$issue->status = $this->request->post('status', 'integer');
			$issue->visible = $this->request->post('visible', 'integer');

			$issue->assignment = $this->request->post('assignment');
			$issue->email_guest = $this->request->post('email_guest');
			
			$issue->assigned = $this->request->post('assigned');
			$issue->details = $this->request->post('details');


			//$date_start	= $this->request->post('date_start', 'string');
			$date_start	=  date('d.m.Y', strtotime($this->request->post('date_start')));
			$time_start	= $this->request->post('time_start');
			$issue->date_start = date('Y-m-d G:i:s', strtotime($date_start.' '.$time_start.':00'));

			$date_completion	= $this->request->post('date_completion', 'string');
			if(!empty($date_completion))
			{
				$date_completion	=  date('d.m.Y', strtotime($date_completion));
				$time_completion	= $this->request->post('time_completion');
				$issue->date_completion = date('Y-m-d G:i:s', strtotime($date_completion.' '.$time_completion.':00'));
			}
			else 
				$issue->date_completion = null;
			

			if(empty($issue->assignment))
			{			
				$this->design->assign('message_error', 'empty_assignment');
			}
			else
			{
				// Add
				if(empty($issue->id))
				{
					$issue->id = $this->issues->add_issue($issue);
					$this->design->assign('message_success', 'added');
	   	    		$issue = $this->issues->get_issue(intval($issue->id));
				}
				// Update
				else
				{
					$issue->id = $this->issues->update_issue($issue->id, $issue);
	  				$this->design->assign('message_success', 'updated');
	   	    		$issue = $this->issues->get_issue(intval($issue->id));
				}
				
			}
		}


		$id = $this->request->get('id', 'integer');
		if(!empty($id))
			$issue = $this->issues->get_issue(intval($id));			

		if(!empty($issue))
		{
			$this->design->assign('issue', $issue);
		}
		
 		$houses = $this->pages->get_pages(array('menu_id'=>5, 'not_tree'=>1));
		if(!empty($houses))
			$houses= $this->categories_tree->get_categories_tree('houses', $houses);
		$this->design->assign('houses', $houses);

		$this->design->assign('statuses', array('Not started', 'In progress', 'Done'));
		
 	  	return $this->design->fetch('issue.tpl');
	}
	
}

