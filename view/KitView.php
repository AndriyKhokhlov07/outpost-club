<?PHP

/**
 *
 * @copyright 	2015 Dmitriy Kozik
 * @email		dmitriy-kozik@ukr.net
 *
 * Этот класс использует шаблон kit.tpl
 *
 */
require_once('View.php');

class KitView extends View
{
	function fetch(){
		
		// Параметры, пердаваемые через Ajax
		
		// Свойства
		$f_options = array();
		$f_options = $this->request->get('f');
		
		// Id товара, index - тип товара (фронтальная акустика...)
		$q_product_id = $this->request->get('p', 'integer');
		$q_index	  = $this->request->get('i', 'integer');
		$q_affects	  = $this->request->get('a', 'integer');
		/*if(!empty($q_affects))
			$q_affects = explode(',', $q_affects);*/
		
		/*if(!empty($q_product_id)){
			echo $q_product_id;
			echo '
';
			echo $q_index;
			echo '
';
			print_r( $q_affects );
			
			
			
			
			exit;
		}*/
		

		if(empty($q_product_id) && empty($q_index)){
		
			// ID свойств, учавствующих в подборе
			$features_ids = array(
				300, // Площадь помещения
				301  // Вариант системы
			);
			$features = array();
			foreach($this->features->get_features(array('id'=>$features_ids)) as $f)
				$features[$f->id] = $f;
				
			$options = $this->features->get_options(array('feature_id'=>$features_ids));
			foreach($options as $option)
				if(isset($features[$option->feature_id]))
					$features[$option->feature_id]->options[] = $option;
			
			if(!empty($f_options)){
				$features_options = array();
				foreach($f_options as $feature_id=>$option_value){
					if(in_array((int)$feature_id, $features_ids) && $option_value !='')
						$features_options[$feature_id] = array(strval($option_value));
				}
			}
		
		}
		
	
		$products = array();
		$products_ids = array();
		
		
		if($q_index != 1){
			// Напольная акустика
			$filter = array();
			$filter['visible'] = 1;
			$filter['limit'] = 10;
			// Опции по Ajax
			if(!empty($features_options))
				$filter['features'] = $features_options;
			// Опции в ручную
			$filter['features'][299] = array('Фронт');	   // Тип АС
			$filter['features'][303] = array('Напольная'); // Подтип АС
			$filter['features'][302] = array('Корпусная');  // Формфактор АС
			
			$products[1] = new stdClass;
			foreach($this->products->get_products($filter) as $p){
				$products[1]->data[$p->id]  = $p;
				$products_ids[$p->id] = $p->id;
			}
			if(!empty($products[1])){
				// Какие группы товаров обновлять после выбора из текущей группы
				$products[1]->set->affects = array(
					2, // Центр
					3  // Тыл
				);
				//$so_params['product_id'] = $products_ids;
				//$so_params_category = $this->categories->get_category(11); // Акустические системы 
				//$so_params['category_id'] = $so_params_categor->children;
				/*$so_params['category_id'] = array(
					12, // Напольная
					13, // Полочная
					25, // Настенная
					26, // Встраиваемая
				);*/
				$so_params['feature_id'] = array(
					302 // Формфактор АС
				);
				$products[1]->set->features = array();
				foreach($this->features->get_options($so_params) as $so)
					$products[1]->set->features[$so->feature_id][$so->id] = $so;
			}
		}

		if(
			!empty($products[1]) || 
			(!empty($q_product_id) && $q_index == 1)
		){
			// Первый товар
			$products1 = $products[1]->data;
			if(!empty($products1))
				$product1 = current($products1);
			// Совместимые товары
			$product1_compatibility = array();
			$product1_compatibility_ids = array();
			
			if($q_index == 1 && !empty($q_product_id))
				$product1->id = $q_product_id;
				
			foreach($this->products->get_products_compatibility($product1->id) as $pc){
				$tmp_pc = new stdClass;
				$tmp_pc = $pc;
				if($pc->product2_id == $product1->id){
					$tmp_pc->product2_id = $pc->product1_id;
					$tmp_pc->product1_id = $pc->product2_id;
				}
				$product1_compatibility[] = $tmp_pc;
				$product1_compatibility_ids[] = $tmp_pc->product2_id;
			}
			$filter_options = array();
			$filter_options['product_id'] = array($product1->id);
			$filter_options['feature_id'] = array(
												302, // Формфактор
												167, // Серия
												183  // Цвет
											);
			$product1_options = $this->features->get_options($filter_options);
			
			
			// Центральный канал
			if(
				empty($q_product_id) ||
				(!empty($q_product_id) && $q_affects == 2)
			){	
				$filter = array();
				$filter['visible'] = 1;
				$filter['limit'] = 10;
				$filter['features'][299] = array('Центр'); // Тип акустики
				if(!empty($product1_compatibility_ids)) // Совместимые товары
					$filter['id'] = $product1_compatibility_ids;
					
				elseif(!empty($product1_options)) // Если нет совместимых, выбираем опции для совпадений
					foreach($product1_options as $o)
						$filter['features'][$o->feature_id][] = $o->value;
	
				foreach($this->products->get_products($filter) as $p){
					$products[2]->data[$p->id]  = $p;
					$products_ids[$p->id] = $p->id;
				}
				if(!empty($product1_compatibility_ids) && !empty($product1_options) && count($products[2]->data) < $filter['limit']){
					// Не выбераем совместимые товары
					unset($filter['id']);
					// Не выбераем уже выбранные
					$filter['no_id'] = array_keys($products[2]->data);
					// Ищем по опциям
					foreach($product1_options as $o)
						$filter['features'][$o->feature_id][] = $o->value;
						
					foreach($this->products->get_products($filter) as $p){
						$products[2]->data[$p->id]  = $p;
						$products_ids[$p->id] = $p->id;
					}
				}
				
				if(!empty($products[2])){
					$so_params['feature_id'] = array(
						302 // Формфактор АС
					);
					$products[2]->set->features = array();
					foreach($this->features->get_options($so_params) as $so)
						$products[2]->set->features[$so->feature_id][$so->id] = $so;
				}
			
			}
			
			
			// Полочная акустика (Тыл)
			if(
				empty($q_product_id) ||
				(!empty($q_product_id) && $q_affects == 3)
			){	
				$filter = array();
				$filter['visible'] = 1;
				$filter['limit'] = 10;
				$filter['features'][299] = array('Тыл'); // Тип акустики
				
				if(!empty($product1_compatibility_ids)) // Совместимые товары
					$filter['id'] = $product1_compatibility_ids;
				elseif(!empty($product1_options)) // Если нет совместимых, выбираем опции для совпадений
					foreach($product1_options as $o)
						$filter['features'][$o->feature_id][] = $o->value;
				
				foreach($this->products->get_products($filter) as $p){
					$products[3]->data[$p->id]  = $p;
					$products_ids[$p->id] = $p->id;
				}
				
				if(!empty($product1_compatibility_ids) && !empty($product1_options) && count($products[3]->data) < $filter['limit']){
					// Не выбераем совместимые товары
					unset($filter['id']);
					// Не выбераем уже выбранные
					$filter['no_id'] = array_keys($products[3]->data);
					// Ищем по опциям
					foreach($product1_options as $o)
						$filter['features'][$o->feature_id][] = $o->value;
						
					foreach($this->products->get_products($filter) as $p){
						$products[3]->data[$p->id]  = $p;
						$products_ids[$p->id] = $p->id;
					}
				}
			}
			
			
			
			$variants = array();
			foreach($this->variants->get_variants(array('product_id'=>$products_ids, 'in_stock'=>true)) as $variant)
				$variants[$variant->product_id][] = $variant;
			
			$images = array();
			foreach($this->products->get_images(array('product_id'=>$products_ids)) as $image)
				$images[$image->product_id][] = $image;
				
			foreach($products as &$products_arr)
				foreach($products_arr->data as $p){
					$p->variants = $variants[$p->id];
					$p->variant =  $p->variants[0];
					$p->images = $images[$p->id];
					$p->image =  $p->images[0];
				}
			
			
		}
		
		
		
		$this->design->assign('products', $products);
		
		
		//print_r($product1); exit;
		
		/*
		$this->design->assign('page', $page);
		$this->design->assign('meta_title', $page->meta_title);
		$this->design->assign('meta_keywords', $page->meta_keywords);
		$this->design->assign('meta_description', $page->meta_description);
		*/
		
		$this->design->assign('features', $features);
		
		if(!empty($features_options) || !empty($q_product_id)){
			print $this->design->fetch('kit/kit_wrapper.tpl');
			exit;
		}
		else
			return $this->design->fetch('kit.tpl');
	}
}