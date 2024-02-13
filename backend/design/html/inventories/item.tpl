{* Вкладки *}
{capture name=tabs}
	<li>
		<a href="index.php?module=InventoriesHousesAdmin&type=1">Restocking</a>
		{if $new_restokings[1]}
			<div class='counter'>{$new_restokings[1]['count']}</div>
		{/if}
	</li>
	<li>
		<a href="index.php?module=InventoriesHousesAdmin&type=2">Kitchen restocking</a>
		{if $new_restokings[2]}
			<div class='counter'>{$new_restokings[2]['count']}</div>
		{/if}
	</li>
	
	<li><a href="index.php?module=InventoriesGroupsAdmin">Groups</a></li>
	<li class="active"><a href="index.php?module=InventoriesItemsAdmin">Items</a></li>
{/capture}

{if $item->id}
{$meta_title = $item->name scope=parent}
{else}
{$meta_title = 'New item' scope=parent}
{/if}

{include file='tinymce_init.tpl'}

{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success=='added'}{$item->name|escape} was created{elseif $message_success=='updated'}{$item->name|escape} was updated{else}{$message_success}{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{$message_error}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}

<!-- Основная форма -->
<form method=post id=product>

	<div id="name">
		<input class="name feature_name" name=name type="text" value="{$item->name|escape}"/>
		<input class="name unit" name=unit type="text" value="{$item->unit|escape}" placeholder="pcs" />
		<div class="checkbox">
			<input name=visible value='1' type="checkbox" id="active_checkbox" {if $item->visible}checked{/if}/> <label for="active_checkbox">Enabled</label>
		</div>

		<input name=id type="hidden" value="{$item->id|escape}"/> 
	</div> 

	<div class="block">
		<ul>
			<li>
				<label class=property>Type</label>
				<select name="type">
					<option value='1' {if $item->type==1}selected{/if}>Restocking</option>
					<option value='2' {if $item->type==2}selected{/if}>Kitchen restocking</option>
				</select>
			</li>
		</ul>
	</div>


	<!-- Левая колонка свойств товара -->
	<div id="column_left">

		<div class="block">
			<h2>Apply to groups</h2>
			<select class=multiple_categories multiple name="item_groups[]">
				{function name=group_select level=0}
				{if $groups}
					{foreach $groups as $group}
							<option value='{$group->id}' {if in_array($group->id, $item_groups)}selected{/if}>{section name=sp loop=$level}&nbsp;&nbsp;&nbsp;&nbsp;{/section}{$group->name} {if $group->type==1}(Restocking){elseif $group->type==2}(Kitchen restocking){/if}</option>
							{group_select groups=$group->subcategories  level=$level+1}
					{/foreach}
				{/if}
				{/function}
				{group_select groups=$groups}
			</select>
		</div>
 
	</div>
	<!-- Левая колонка свойств товара (The End)--> 
	
	<!-- Правая колонка свойств товара -->	
	<div id="column_right">

		<div class="block">
		<h2>Apply to houses</h2>
			<select class=multiple_categories multiple name="item_houses[]">
				{function name=house_select level=0}
				{if $houses_}
					{foreach $houses_ as $house}
						<option value='{$house->id}' {if in_array($house->id, $item_houses)}selected{/if}>{section name=sp loop=$level}&nbsp;&nbsp;&nbsp;&nbsp;{/section}{$house->name}</option>
							{if $house->subcategories}
								{house_select houses_=$house->subcategories level=$level+1}
							{/if}
					{/foreach}
				{/if}
				{/function}
				{house_select houses_=$houses}
			</select>
		</div>
		
		
	</div>
	<!-- Правая колонка свойств товара (The End)--> 
	<div class="clear"></div>

	<!-- Описагние категории -->
	<div class="block layer">
		<h2>Description</h2>
		<textarea name="description" class="editor_small">{$item->description|escape}</textarea>
	</div>

	<input type=hidden name='session_id' value='{$smarty.session.id}'>
	<input class="button_green" type="submit" name="" value="Save" />
	

</form>
<!-- Основная форма (The End) -->

