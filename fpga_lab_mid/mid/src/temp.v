for(i=0;i<5;i=i+1)
begin
    case(houseCards_rf[i])
        'd0:
        begin
            seg7_house_converted[i] <= SEG_RESET;
        end
        'd1:
        begin
            seg7_house_converted[i] <= SEG_ONE;
        end
        'd2:
        begin
            seg7_house_converted[i] <= SEG_TWO;
        end
        'd3:
        begin
            seg7_house_converted[i] <= SEG_THREE;
        end
        'd4:
        begin
            seg7_house_converted[i] <= SEG_FOUR;
        end
        'd5:
        begin
            seg7_house_converted[i] <= SEG_FIVE;
        end
        'd6:
        begin
            seg7_house_converted[i] <= SEG_SIX;
        end
        'd7:
        begin
            seg7_house_converted[i] <= SEG_SEVEN;
        end
        'd8:
        begin
            seg7_house_converted[i] <= SEG_EIGHT;
        end
        'd9:
        begin
            seg7_house_converted[i] <= SEG_NINE;
        end
        'd10:
        begin
            seg7_house_converted[i] <= SEG_TEN;
        end
    endcase
end
