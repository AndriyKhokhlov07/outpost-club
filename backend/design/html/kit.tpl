{* Вкладки *}
{capture name=tabs}
	<li><a href="index.php?module=ProductsAdmin">Товары</a></li>
    <li class="active"><a href="index.php?module=KitsGroupsAdmin">Комплекты</a></li>
	<li><a href="index.php?module=CategoriesAdmin">Категории</a></li>
	<li><a href="index.php?module=BrandsAdmin">Бренды</a></li>
	<li><a href="index.php?module=FeaturesAdmin">Свойства</a></li>
{/capture}

{if $kit->id}
{$meta_title = $kit->name scope=parent}
{else}
{$meta_title = 'Новый комплект' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}

{* On document load *}
{literal}
<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>

<script src="design/js/autocomplete/jquery.autocomplete-min.js"></script>
<style>
.autocomplete-suggestions{
background-color: #ffffff;
overflow: hidden;
border: 1px solid #e0e0e0;
overflow-y: auto;
}
.autocomplete-suggestions .autocomplete-suggestion{cursor: default;}
.autocomplete-suggestions .selected { background:#F0F0F0; }
.autocomplete-suggestions div { padding:2px 5px; white-space:nowrap; }
.autocomplete-suggestions strong { font-weight:normal; color:#3399FF; }
</style>


<script>
$(function() {
	
	// Сортировка связанных товаров
	$(".sortable").sortable({
		items: "div.row",
		tolerance:"pointer",
		scrollSensitivity:40,
		opacity:0.7,
		handle: '.move_zone'
	});
	
	// Удаление связанного товара
	$(".kits_products a.delete").live('click', function() {
		 $(this).closest("div.row").fadeOut(200, function() { $(this).remove(); });
		 return false;
	});
	
	// Добавление связанного товара 
	var new_kits_product = $('#new_kits_product').clone(true);
	$('#new_kits_product').remove().removeAttr('id');
 
	$("input#kits_products").autocomplete({
		serviceUrl:'ajax/search_products_variants.php',
		minChars:0,
		noCache: false, 
		onSelect:
			function(suggestion){
				new_item = new_kits_product.clone().appendTo('.kits_products');
				new_item.removeAttr('id');
				new_item.find('a.kit_product_name').html(suggestion.data.name);
				new_item.find('.variant_name').html(suggestion.data.variant_name);
				new_item.find('.variant_price span').html(suggestion.data.price);
				new_item.find('a.kit_product_name').attr('href', 'index.php?module=ProductAdmin&id='+suggestion.data.id);
				new_item.find('input[name*="variant_id"]').val(suggestion.data.variant_id);
				if(suggestion.data.image)
					new_item.find('img.product_icon').attr("src", suggestion.data.image);
				else
					new_item.find('img.product_icon').remove();
				$("#kits_products").val(''); 
				new_item.show();
			},
		formatResult:
			function(suggestions, currentValue){
				var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
				var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
  				return (suggestions.data.image?"<img align=absmiddle src='"+suggestions.data.image+"'> ":'') + suggestions.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>')+ ' ' + suggestions.data.variant_name;
			}

	});

	
});




</script>


{/literal}


{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span>{if $message_success == 'added'}Комплект добавлен{elseif $message_success == 'updated'}Комплект обновлен{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Вернуться</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}




<!-- Основная форма -->
<form method="post" id="product" enctype="multipart/form-data">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
    <input name="id" type="hidden" value="{$kit->id|escape}"/> 

	<!-- Левая колонка свойств товара -->
	<div id="column_left">
    	<div class="block layer">
			<ul>
                <li><label class=property>Название комплекта</label><input name="name" class="backend_inp" type="text" value="{$kit->name|escape}" /></li>
                <li><label class=property for="active_checkbox">Активен</label><input name="visible" value='1' type="checkbox" id="active_checkbox" {if $kit->visible}checked{/if}/></li>
				<li><label class=property>Описание</label><textarea name="description" class="backend_inp" />{$kit->description|escape}</textarea></li>
			</ul>
		</div>

	</div>
	<!-- Левая колонка свойств товара (The End)--> 
	
    	
	<!-- Правая колонка свойств товара -->	
	<div id="column_right">
		
		<div class="block layer">
			<h2>Товары комплекта</h2>
			<div id=list class="sortable kits_products">
				{foreach from=$kits_products item=kits_product}
				<div class="row">
                	<div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type="hidden" name="kit_products[variant_id][]" value="{$kits_product->variant->id}">
					<a href="{url module=ProductAdmin id=$kits_product->id}">
					<img class=product_icon src='{$kits_product->images[0]->filename|resize:product:35:35}'>
					</a>
					</div>
					<div class="name cell">
					<a href="{url module=ProductAdmin id=$kits_product->id}">{$kits_product->name}</a>
                    <span class="variant_name">{$kits_product->variant->name}</span>
                    <div class="variant_price"><span>{$kits_product->variant->price}</span> {$currency->sign}</div>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
                     <div class="kit_setting">
                    <label class=property>Скидка</label><input name="kit_products[discount][]" class="coupon_value" type="text" value="{$kits_product->discount|escape}" />
					<select class="coupon_type" name="kit_products[discount_type][]">
						<option value="1" {if $kits_product->discount_type==1}selected{/if}>%</option>
						<option value="2" {if $kits_product->discount_type==2}selected{/if}>{$currency->sign}</option>
					</select>
                    </div>
                    <div class="clear"></div>
				</div>
				{/foreach}
				<div id="new_kits_product" class="row" style='display:none;'>
                <div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type="hidden" name="kit_products[variant_id][]" value="">
					<img class=product_icon src=''>
					</div>
					<div class="name cell">
					<a class="kit_product_name" href=""></a>
                    <span class="variant_name"></span>
                    <div class="variant_price"><span></span> {$currency->sign}</div>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
                    <div class="kit_setting">
                    <label class=property>Скидка</label><input name="kit_products[discount][]" class="coupon_value" type="text" value="5" />
					<select class="coupon_type" name="kit_products[discount_type][]">
						<option value="1">%</option>
						<option value="2">{$currency->sign}</option>
					</select>
                    </div>
                    <div class="clear"></div>
                    
				</div>
			</div>
			<input type=text name=related id='kits_products' class="input_autocomplete" placeholder='Выберите товар чтобы добавить его'>
		</div>
	</div>
	<!-- Правая колонка свойств товара (The End)--> 
    
	<input class="button_green button_save" type="submit" name="" value="Сохранить" />

	
</form>
<!-- Основная форма (The End) -->

