BEGIN{
	cbr_send = 0;
	cbr_recv = 0;
	
}
{
	if ($1 == "+" && $3 =="0" && $5 == "cbr"){cbr_send++;}
	if ($1 == "r" && $3 =="4" && $4 =="5" && $5 == "cbr"){cbr_recv++;}
	if ($1 == "r" && $3 =="3" && $4 =="4" && $5 == "cbr"){cbr_recv++;}
        if ($1 == "r" && $4 =="3" && $3 =="2" && $5 == "cbr"){cbr_recv++;}
        if ($1 == "r" && $4 =="2" && $3 =="1" && $5 == "cbr"){cbr_recv++;}
        if ($1 == "r" && $4 =="1" && $3 =="0" && $5 == "cbr"){cbr_recv++;}
}

END{
printf("\nCBR packets sent: %d",cbr_send);
printf("\nCBR packets received: %d", cbr_recv);
printf("\nCBR packets delivery ratio :\t %f",(cbr_recv/cbr_send)*100);

printf("\n");
}
