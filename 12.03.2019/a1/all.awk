BEGIN {
	seqno = -1;  
	count = 0;
	recvdSize = 0
	startTime = 1
	stopTime = 0
	sent=0
	receive=0
}

{
	event = $1
	time = $2
	node_id = $3
	pkt_size = $6
	level = $4

	if (event == "+" && $5 == "cbr") {
        sent++	
	if (time < startTime) {
		startTime = time
		}
	}
	
	if ( event == "-" && $5 == "cbr") {
	    receive++
	if (time > stopTime) {
		stopTime = time
		}
	recvdSize += pkt_size
        }
	if($1 == "+" && seqno < $11) {

          seqno = $11;

    }

    if( $1 == "+") {

          start_time[$11] = $2;

    } else if(($5 == "cbr") && ($1 == "-")) {

        end_time[$11] = $2;

    } else if($1 == "D" && $7 == "cbr") {

          end_time[$11] = -1;

    } 
}
	
END {
printf"sent_packets\t %d",sent;	
printf"\nreceived_packets %d",receive;
printf"\nPacket Delivery Ratio %.2f",(receive/sent)*100;		
printf"\nAverage Throughput[kbps] = %.2f\n", (recvdSize/(stopTime-startTime))*(8/1000);

for(i=0; i<=seqno; i++) {

          if(end_time[i] > 0) {

              delay[i] = end_time[i] - start_time[i];

                  count++;

        }

            else

            {

                  delay[i] = -1;

            }

    }

    for(i=0; i<=seqno; i++) {

          if(delay[i] > 0) {

              n_to_n_delay = n_to_n_delay + delay[i];

        }         

    }
   n_to_n_delay = n_to_n_delay/count;
    print "\nAverage End-to-End Delay    = " n_to_n_delay * 1000 " ms";
}
