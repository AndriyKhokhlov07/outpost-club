<?php
session_start();

require_once('../api/Backend.php');

class Sc extends Backend
{
	function fetch() {

		$lead = new stdClass;
        $lead->site = 'outpost-club.com';
        $lead->form_type = $this->request->post('form_type', 'integer');

		$lead->first_name = $this->request->post('firstname');
		$lead->last_name = $this->request->post('lastname');
		$lead->email = $this->request->post('email');
		$lead->phone = $this->request->post('phone');
        if ($this->request->post('gender')) {
            $lead->gender = $this->request->post('gender', 'string');
        }

		$lead->application_house_id = $this->request->post('house_id', 'integer');
		

        $lead->move_in_date = $this->request->post('move_in_date', 'string');
        if ($this->request->post('move_out_date1')) { 
            $lead->move_out_date = $this->request->post('move_out_date1', 'string');
        }
        if ($this->request->post('dates_flexible')) { 
            $lead->dates_flexible = $this->request->post('dates_flexible', 'string');
        }
        if ($this->request->post('budget')) { 
            $lead->budget = $this->request->post('budget', 'string');
        }
        if ($this->request->post('how_long_do_you_plan_to_stay')) { 
            $lead->living_period = $this->request->post('how_long_do_you_plan_to_stay', 'string');
        }

        if ($this->request->post('budgets')) {
            $lead->budgets = $this->request->post('budgets'); // array
        }
        if ($this->request->post('refers')) {
            $lead->refers = $this->request->post('refers'); // array
        }
        

        

        if ($this->request->post('stay_alone')) {
            $lead->stay_alone = $this->request->post('stay_alone');

            if ($lead->stay_alone == 'No') {
                if ($this->request->post('first_name___guest')) {
                    $lead->guest_first_name = $this->request->post('first_name___guest');
                }
                if ($this->request->post('guest_last_name')) {
                    $lead->guest_last_name = $this->request->post('guest_last_name');
                }
                if ($this->request->post('guest_email')) {
                    $lead->guest_email = $this->request->post('guest_email');
                }
                if ($this->request->post('guest_phone_number')) {
                    $lead->guest_phone = $this->request->post('guest_phone_number');
                }
            }
        }

        
        

        if ($this->request->post('mason_room_type')) {
            $lead->room_type = $this->request->post('mason_room_type');
        }
        

        if ($this->request->post('what_third_party_listing_website_did_you_find_us_on_')) {
            $lead->listing_website = $this->request->post('what_third_party_listing_website_did_you_find_us_on_');
        }

        if ($this->request->post('name_of_apartment_listing_website')) {
            $lead->apartment_listing_website = $this->request->post('name_of_apartment_listing_website');
        }

        if ($this->request->post('name_of_friend')) {
            $lead->friend_name = $this->request->post('name_of_friend');
        }

        if ($this->request->post('corporate_referral_code')) {
            $lead->corporate_referral_code = $this->request->post('corporate_referral_code');
        }

        if ($this->request->post('code')) {
            $lead->code = $this->request->post('code');
        }

        

        if ($this->request->post('additional_info')) {
            $lead->additional_info = $this->request->post('additional_info');
        }
        

        $selected_houses = $this->request->post('selected_houses'); // array
        if (!empty($selected_houses) && is_array($selected_houses)) {

            $houses_pages = $this->pages->get_pages([
                'menu_id' => 5,
                'not_parent_id' => 0
            ]);
            $houses_names_ids = [];
            if (!empty($houses_pages)) {
                foreach($houses_pages as $h) {
                    if (!empty($h->nebo_id)) {
                        $houses_names_ids[strtolower(trim($h->header))] = $h->nebo_id;
                    }
                }
            }

            $lead->selected_houses_ids = [];
            $lead->selected_houses_names = [];
            foreach($selected_houses as $k=>$house_name) {
                if ($house_name == 'The Mason') {
                    $house_name = 'The Mason on Chestnut';
                }
                if (isset($houses_names_ids[strtolower(trim($house_name))])) {
                    $lead->selected_houses_ids[$houses_names_ids[strtolower(trim($house_name))]] = trim($house_name);
                }
                else {
                    $lead->selected_houses_names[] = trim($house_name);
                }
            }
        }
        
        
		foreach ($lead as $k_l=>$l) {
            if (is_array($l)) {
                foreach($l as $k_ll=>$ll) {
                    $lead->$k_l[$k_ll] = trim($ll);
                }
            }
            else {
                $lead->$k_l = trim($l);
            }
        }

        

        

		$this->get_curl($lead);

		$this->echo_json([
			'content' => 'User added'
		]);


		// $this->add_log();
        // $this->add_log($lead);
	}

    // Request to NeBo
	function get_curl($data) {
		$url = 'https://ne-bo.com/ajax/add_lead.php';
		if ($this->config->host == 'dev') {
			$url = 'http://nebo/ajax/add_lead.php';
		}

        $data = (array)$data;

		$curl = curl_init();
		curl_setopt($curl, CURLOPT_URL, $url);
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_POST, true);
		curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 5);
		curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query($data));
		$json = curl_exec($curl);

		$http_status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
		curl_close($curl);
	}


	function echo_json($data) {
		header("Content-type: application/json; charset=UTF-8");
		header("Cache-Control: must-revalidate");
		header("Pragma: no-cache");
		header("Expires: -1");
		echo json_encode($data);
	}



	// Log in file
	function logg($str)
	{
		file_put_contents('log.txt', file_get_contents('log.txt')."\r\n".date("m.d.Y H:i:s").' '.$_SERVER['REMOTE_ADDR'].' '.$str);
	}
	function add_log($data = false) {
		$postData = file_get_contents('php://input');
		if(!empty($postData)) {
			$this->logg('json: '.http_build_query($postData));	
		}
        elseif(!empty($data)) {
            foreach($data as $key=>$value) {
                if (is_array($value)) {
                    foreach($value as $k=>$v) {
                        $this->logg('log: '.$key.'['.$k.'] => ('.$v.')');
                    }
                }
                else {
                    $this->logg('log: '.$key.' => ('.$value.')');
                }	
			}
        }
		elseif (!empty($_POST)) {
			foreach($_POST as $key=>$value) {
                if (is_array($value)) {
                    foreach($value as $k=>$v) {
                        $this->logg('post: '.$key.'['.$k.'] => ('.$v.')');
                    }
                }
                else {
                    $this->logg('post: '.$key.' => ('.$value.')');
                }	
			}	
		}
		else {
			$this->logg('post empty');
		}	
	}


}


$sc = new Sc();
$sc->fetch();

