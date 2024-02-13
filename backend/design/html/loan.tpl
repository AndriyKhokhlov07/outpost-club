{capture name=tabs}
	{if in_array('pages', $manager->permissions)}
	{foreach from=$menus item=m}
		<li><a href='?module=PagesAdmin&menu_id={$m->id}'>{$m->name}</a></li>
	{/foreach}
	{/if}
	<li class="active"><a href="{url module=LoansAdmin menu_id=null}">Вадачи</a></li>
	<li><a href="{url module=GalleryAdmin id=1 menu_id=null}">Благодарности</a></li>
{/capture}

{if $loan->id}
{$meta_title = $loan->name scope=parent}
{else}
{$meta_title = 'Новая Выдача' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}

{* On document load *}
{literal}
<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>

<script>
$(function() {
	// Удаление изображений
	$(".images a.delete").click( function() {
		$("input[name='delete_image']").val('1');
		$(this).closest("ul").fadeOut(200, function() { $(this).remove(); });
		return false;
	});
});
</script>


{/literal}


{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success == 'added'}Выдача добавлена{elseif $message_success == 'updated'}Выдача обновлена{/if}</span>
	{if $smarty.get.return}
		<a class="button" href="{$smarty.get.return}">Вернуться</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<a class="button" href="">Вернуться</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}



<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
	<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$loan->name|escape}"/> 
		<input name=id type="hidden" value="{$loan->id|escape}"/> 
		<div class="checkbox">
			<input name=visible value='1' type="checkbox" id="active_checkbox" {if $loan->visible}checked{/if}/> <label for="active_checkbox">Активна</label>
		</div>
	</div> 

		

	<!-- Левая колонка свойств товара -->
	<div id="column_left">
    
    	<!-- Параметры страницы -->
		<div class="block">
			<ul>
				<li><label class=property>Тип</label>	
					<select name="type">
						<option value='2' {if $loan->type==2}selected{/if}>Недвижимость</option>
				        <option value='1' {if $loan->type==1}selected{/if}>Авто в ходу</option>
				        <option value='3' {if $loan->type==3}selected{/if}>Авто на стоянке</option>
					</select>		
				</li>
				<li><label class=property>Цена</label><input name="price" class="backend_inp" type="text" value="{$loan->price}" /></li>
			</ul>
		</div>
		<!-- Параметры страницы (The End)-->

		<div class="block">
	        <h2>Описание</h2>
	        <textarea name="description" class="annotation">{$loan->description|escape}</textarea>
	    </div>

	</div>
	<!-- Левая колонка свойств страницы  (The End)--> 
    
    <!-- Правая колонка свойств страницы -->	
	<div id="column_right">
	
		<!-- Изображение страницы  -->	
		<div class="block images">
			<h2>Изображение</h2>
			<input class='upload_image' name=image type=file>			
			<input type=hidden name="delete_image" value="">
			{if $loan->image}
			<ul>
				<li>
					<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
					<img src="../{$config->loans_images_dir}{$loan->image}" alt="" />
				</li>
			</ul>
			{/if}
		</div>
		
	</div>
	<!-- Правая колонка свойств страницы (The End)--> 
    
    
   <div style="clear:both"></div>
    
	<input class="button_green button_save" type="submit" name="" value="Сохранить" />
	
</form>
<!-- Основная форма (The End) -->

