BEGIN{
	cbr_send = 0;
	cbr_recv = 0;
	tcp_send = 0;
	tcp_recv = 0;
}
{
	if ($1 == "+" && $3 =="3" && $5 == "cbr"){cbr_send++;}
	if ($1 == "r" && $4 =="5" && $5 == "cbr"){cbr_recv++;}
	if ($1 == "+" && $3 =="2" && $5 == "tcp"){tcp_send++;}
	if ($1 == "r" && $4 =="4" && $5 == "tcp"){tcp_recv++;} 
}

END{
printf("\nCBR packets sent: %d",cbr_send);
printf("\nCBR packets received: %d", cbr_recv);
printf("\nCBR packets delivery ratio :\t %f",(cbr_recv/cbr_send)*100);
printf("\nTCP packets sent: %d",tcp_send);
printf("\nTCP packets received: %d", tcp_recv);
printf("\nTCP packets delivery ratio :\t %f",(tcp_recv/tcp_send)*100);
printf("\n");
}
