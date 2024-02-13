<?php

$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://apiv2.qira.com/apiV2/Processing-Fees?payeeId=A20FE25F-0870-40D0-A1D8-0399406713D1&amount=1000",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_CUSTOMREQUEST => "GET",
    CURLOPT_CONNECTTIMEOUT => 120,
    CURLOPT_TIMEOUT        => 120,
    CURLOPT_HTTPHEADER => [
        'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im54ZWNYamw3ejhWTFJfMVByMWJBbWQ1dlNqSUNwcHVxZnh4YXg3RVY2dDQifQ.eyJqdGkiOiI4NTViZjIxNC05ZmZhLTQ3NWEtOWM0ZS1hYmE2YjdiOTIwNGMiLCJyb2xlIjoicmVudGlnby12Mi1hcGktY2xpZW50Iiwib3JnYW5pemF0aW9uLWlkIjoiRkUwRkVDMTgtMjE2NC00N0Q1LThBMzktMkYzNkExMTAyNDc5IiwibmJmIjoxNjMyOTkwOTg3LCJleHAiOjE2NjQ1NzE2MDAsImlhdCI6MTYzMjk5MDk4NywiaXNzIjoiUmVudGlnbyBBdXRob3JpemF0aW9uIFNlcnZlciBJc3N1cmUiLCJhdWQiOiJSZW50aWdvLVYyLTEifQ.pNoJJXf3cdXGin0sV_uZutFlAtSGWLqOWH3jpel_j8VlIOK0vS_bxPWnH4AuNGwN4fDMnoclLYMgKGvxxihnKsRGV5sb_JQyNLH8EuFhCzwdho3VH7FRoWkrbS39Ef18Ck3pErAiL_lQw2j4B_U6srUoYboetFbko3aJnIQwhOm7us-1lfVVjhXEfjjgTpAkGI7iVFyw_2QxLOr9OYC_yRsNJdplQ-GlXsIYx3YR11yVql-r45z8K8WgAOoXFL8wUV6pNNp7Qm4gBmSvD3Whp_1ngR2HqH0rW12txAbONT1EeHq94dGO-hoxn4YtgUsxOw6Dxmqq-GZ-OJ2gbpl7_Sm1irq9DSfpfHJiZKk8UGoP_huC8Z6ZHNmz6DLiHLdxzp24u-p_jTLR4XOPLH8BCemeb7QAGX4_I8xG6MW0ZfvD1fQi_hRSmEu6dFXCVVBSIATt8wE3J336YJesBL2xF4mfXfh_K_bdoSorX3tuljDNAFX6sjQJmespNElKZyxdQ7hL3GLOoMlUc1aZ77C7rXV0i6szriNgUKWd89HPR935RO_R6xYpsXD7_CL57ghDYMxB_HDMkXrNsTmPqNyLDkRbb_dxoesfjOskyHH2zzik5bWPPUQvwSkW0TCQhrx_Kaw20K_87jPiwac2X-N2f93YcWqjM9Gz9-bov15vjXw'
    ]
]);

$response = curl_exec($curl);
echo curl_error($curl);
$info = curl_getinfo($curl);

print_r($info); exit;

$result = json_decode($response);

var_dump($result);
exit;
