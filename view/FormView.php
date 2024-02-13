<?PHP
 
require_once('View.php');

class FormView extends View
{
	
	public function __construct() {
		parent::__construct();
		if(!empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest')
		{
			$result['status'] = false;
			
			$name  = $this->request->post('name');
			$value = $this->request->post('value');
			$step  = $this->request->get('s1');
			$form = array();
			if(!empty($value))
			foreach($value as $k=>$v)
			{
				if(!empty($v))
				{
					if(is_array($v))
					{
						foreach($v as $ks=>$vs)
						{
							if(!empty($vs))
							{
								$form[$k]->value[$ks] = $vs;
								$form[$k]->name	= $name[$ks];
							}
						}
						
					}
					else
					{
						$form[$k]->value = $v;
						$form[$k]->name  = $name[$k];
					}
				}
			}
			
			if(!empty($form))
			{
				// Отправляем письмо
				$this->design->assign('data', $form);
				$this->design->assign('step', $step);
				$subject = 'Анкета';
				if($step == 1)
					$subject .= ' | Шаг 1';
				$this->design->assign('subject_', $subject);
				$email_template = $this->design->fetch($this->config->root_dir.'backend/design/html/email_forms_admin.tpl');
				$this->notify->email($this->settings->comment_email, $subject, $email_template, $this->settings->notify_from_email);
				$result['status'] = true;
			}

			header("Content-type: application/json; charset=UTF-8");
			header("Cache-Control: must-revalidate");
			header("Pragma: no-cache");
			header("Expires: -1");		
			print json_encode($result);
			exit;
		}
	}
	
	
	function fetch()
	{
		$form = new stdClass;
		if($this->request->method('post'))
		{
			$form->name  = $this->request->post('name');
			$form->value = $this->request->post('value');
			
			$this->design->assign('value', $form->value);
		}

		if($this->page)
		{
			$this->design->assign('meta_title', $this->page->meta_title);
			$this->design->assign('meta_keywords', $this->page->meta_keywords);
			$this->design->assign('meta_description', $this->page->meta_description);
		}

		$body = $this->design->fetch('form.tpl');
		
		return $body;
	}
}
