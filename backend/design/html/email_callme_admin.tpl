{$subject="Обратный звонок" scope=parent}

<h2 style="font-weight:normal;font-family:arial;">Обратный звонок</h2>

<table cellpadding="6" cellspacing="0" style="border-collapse: collapse;">
	<tr>
		<td style="padding:6px; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
			Имя
		</td>
		<td style="padding:6px; width:330px; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
			{$callme->name|escape}
		</td>
	</tr>
	<tr>
		<td style="padding:6px; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
			Телефон
		</td>
		<td style="padding:6px; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
			{$callme->phone|escape}
		</td>
	</tr>
    <tr>
    	<td style="padding:10px;"></td>
        <td style="padding:10px;"></td>
    </tr>
    <tr>
		<td style="padding:6px; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
			Отправленно со страницы
		</td>
		<td style="padding:6px; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
			<a href="{$callme->pageurl}" target="_blank">{$callme->pageurl}</a>
		</td>
	</tr>
	<tr>
		<td style="padding:6px; background-color:#f0f0f0; border:1px solid #e0e0e0;font-family:arial;">
			Дата и время отправки
		</td>
		<td style="padding:6px; background-color:#ffffff; border:1px solid #e0e0e0;font-family:arial;">
			{$callme->date}
		</td>
	</tr>
</table>