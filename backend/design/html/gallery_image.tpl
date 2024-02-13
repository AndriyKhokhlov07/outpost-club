{capture name=tabs}
	<li class="active"><a href="?module=GalleriesAdmin">Galleries</a></li>
{/capture}

{if $image->id}
{$meta_title = $image->name scope=parent}
{else}
{$meta_title = 'New image' scope=parent}
{/if}

{* On document load *}
{literal}
<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>

<script src="design/js/autocomplete/jquery.autocomplete-min.js"></script>

<script>
$(function() {
	
	// Удаление изображений
	$(".images a.delete").click( function() {
		$("input[name='delete_image']").val('1');
		$(this).closest("ul").fadeOut(200, function() { $(this).remove(); });
		return false;
	});
	
	// Сортировка связанных товаров  и услуг
	$(".sortable").sortable({
		items: "div.row",
		tolerance:"pointer",
		scrollSensitivity:40,
		opacity:0.7,
		handle: '.move_zone'
	});
	
	// Удаление связанного товара
	$(".related_products a.delete").live('click', function() {
		 $(this).closest("div.row").fadeOut(200, function() { $(this).remove(); });
		 return false;
	});
 
	// Добавление связанного товара 
	var new_related_product = $('#new_related_product').clone(true);
	$('#new_related_product').remove().removeAttr('id');
 
	$("input#related_products").autocomplete({
		serviceUrl:'ajax/search_products.php',
		minChars:0,
		noCache: false, 
		onSelect:
			function(suggestion){
				$("input#related_products").val('').focus().blur(); 
				new_item = new_related_product.clone().appendTo('.related_products');
				new_item.removeAttr('id');
				new_item.find('a.related_product_name').html(suggestion.data.name);
				new_item.find('a.related_product_name').attr('href', 'index.php?module=ProductAdmin&id='+suggestion.data.id);
				new_item.find('input[name*="related_products"]').val(suggestion.data.id);
				if(suggestion.data.image)
					new_item.find('img.product_icon').attr("src", suggestion.data.image);
				else
					new_item.find('img.product_icon').remove();
				new_item.show();
			},
		formatResult:
			function(suggestions, currentValue){
				var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
				var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
  				return (suggestions.data.image?"<img align=absmiddle src='"+suggestions.data.image+"'> ":'') + suggestions.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
			}

	});
	
	// Удаление связанной услуги
	$(".related_services a.delete").live('click', function() {
		 $(this).closest("div.row").fadeOut(200, function() { $(this).remove(); });
		 return false;
	});
 
	// Добавление связанной услуги
	var new_related_service = $('#new_related_service').clone(true);
	$('#new_related_service').remove().removeAttr('id');
 
	$("input#related_services").autocomplete({
		serviceUrl:'ajax/search_services.php',
		minChars:0,
		noCache: false, 
		onSelect:
			function(suggestion){
				$("input#related_services").val('').focus().blur(); 
				new_item = new_related_service.clone().appendTo('.related_services');
				new_item.removeAttr('id');
				new_item.find('a.related_service_name').html(suggestion.data.name);
				new_item.find('a.related_service_name').attr('href', 'index.php?module=PageAdmin&id='+suggestion.data.id);
				new_item.find('input[name*="related_services"]').val(suggestion.data.id);
				new_item.show();
			},
		formatResult:
			function(suggestions, currentValue){
				var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
				var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
  				return suggestions.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
			}

	});
	

});


</script>

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
{/literal}


{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success == 'added'}Image added{elseif $message_success == 'updated'}Image updated{/if}</span>
	<a class="link" target="_blank" href="../gallery/{$gallery->url}">Open the gallery on the site containing the image</a>
	{if $smarty.get.return}
	<a class="button" href="?module=GalleryAdmin&id={$gallery->id}">Back</a>
	{/if}
	
    {*
	<span class="share">		
		<a href="#" onClick='window.open("http://vkontakte.ru/share.php?url={$config->root_url|urlencode}/{$image->url|urlencode}&title={$image->name|urlencode}&description={$image->body|urlencode}&noparse=false","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/vk_icon.png" /></a>
		<a href="#" onClick='window.open("http://www.facebook.com/sharer.php?u={$config->root_url|urlencode}/{$image->url|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/facebook_icon.png" /></a>
		<a href="#" onClick='window.open("http://twitter.com/share?text={$image->name|urlencode}&url={$config->root_url|urlencode}/{$image->url|urlencode}&hashtags={$image->meta_keywords|replace:' ':''|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/twitter_icon.png" /></a>
	</span>
    *}
	
</div>
<!-- Системное сообщение (The End)-->
{/if}



<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
	<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$image->name|escape}"/> 
		<input name=id type="hidden" value="{$image->id|escape}"/> 
	</div> 

		

	<!-- Левая колонка свойств товара -->
	<div id="column_left">
    

        <!-- Изображение страницы  -->	
		<div class="block images gallery">
			<h2>Image</h2>
			<input class='upload_image' name=image type=file>			
			<input type=hidden name="delete_image" value="">
			{if $image->filename}
			<ul>
				<li>
					<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
					<img src="../{$config->galleries_images_dir}{$image->filename}" alt="" />
				</li>
			</ul>
			{/if}
		</div>
        
        
        <div class="block layer">
            <h2>annotation</h2>
            <textarea name="annotation" class="annotation">{$image->annotation|escape}</textarea>
        </div>

			
	</div>
	<!-- Левая колонка свойств страницы  (The End)--> 
    
    <!-- Правая колонка свойств страницы -->	
	<div id="column_right">

		{*
	
		<div class="block layer">
			<h2>Связанные товары</h2>
			<div id=list class="sortable related_products">
				{foreach from=$related_products item=related_product}
				<div class="row">
					<div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type=hidden name=related_products[] value='{$related_product->id}'>
					<a href="{url id=$related_product->id}">
					<img class=product_icon src='{$related_product->images[0]->filename|resize:product:35:35}'>
					</a>
					</div>
					<div class="name cell">
					<a href="{url id=$related_product->id}">{$related_product->name}</a>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
				</div>
				{/foreach}
				<div id="new_related_product" class="row" style='display:none;'>
					<div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type=hidden name=related_products[] value=''>
					<img class=product_icon src=''>
					</div>
					<div class="name cell">
					<a class="related_product_name" href=""></a>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
				</div>
			</div>
			<input type=text name=related id='related_products' class="input_autocomplete" placeholder='Выберите товар чтобы добавить его'>
		</div>
        
        
        <div class="block layer">
			<h2>Связанные услуги</h2>
			<div id=list class="sortable related_services">
				{foreach from=$related_services item=related_service}
				<div class="row">
					<div class="move cell">
						<div class="move_zone"></div>
					</div>
                    <!-- 
					<div class="image cell">
					<input type=hidden name=related_services[] value='{$related_service->id}'>
					<a href="{url module=PageAdmin id=$related_service->id return=$smarty.server.REQUEST_URI}"></a>
					</div>
                     -->
					<div class="name cell">
					<a href="{url module=PageAdmin id=$related_service->id return=$smarty.server.REQUEST_URI}">{$related_service->name}</a>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
				</div>
				{/foreach}
				<div id="new_related_service" class="row" style='display:none;'>
					<div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type=hidden name=related_services[] value=''>
					</div>
					<div class="name cell">
					<a class="related_service_name" href=""></a>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
				</div>
			</div>
			<input type=text name=related id='related_services' class="input_autocomplete" placeholder='Выберите услугу чтобы добавить'>
		</div>
        *}
		
	</div>
	<!-- Правая колонка свойств страницы (The End)--> 

    
	<input class="button_green button_save" type="submit" name="" value="Save" />
	
</form>
<!-- Основная форма (The End) -->

