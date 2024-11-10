`timescale 1ns / 1ps
module posit_multiplier #(
    parameter WIDTH = 32,
    parameter ES = 3
) (
    input wire clk
//    input wire [31:0] a,
//    input wire [31:0] b,
//    output wire [31:0] res

);
vio_0 your_instance_name (
  .clk(clk),                // input wire clk
  .probe_out0(a),  // output wire [31 : 0] probe_out0
  .probe_out1(b)  // output wire [31 : 0] probe_out1
);

ila_0 yoinstance_name (
	.clk(clk), // input wire clk

	.probe0(res) // input wire [31:0]  probe2
);
    wire [31:0] a;
    wire [31:0] b;
    wire [31:0] res;
    wire sign_a, sign_b, sign_result;
    wire signed [5:0] regime_a, regime_b;
    wire [ES-1:0] exp_a, exp_b;
    wire [WIDTH-6:0] frac_a, frac_b;
    wire [WIDTH-6:0] frac_result;
    wire signed [5:0] regime_result;
    wire [ES-1:0] exp_result;
    wire [WIDTH-1:0] abs_posit_a,abs_posit_b;

    wire is_NaR_a, is_NaR_b, is_zero_a, is_zero_b;

    posit_decoder #(WIDTH, ES) decoder_a (
        .posit(a),
        .sign(sign_a),
        .regime(regime_a),
        .exponent(exp_a),
        .fraction(frac_a),
        .is_NaR(is_NaR_a),
        .is_zero(is_zero_a),
        .abs_posit(abs_posit_a)
    );

    posit_decoder #(WIDTH, ES) decoder_b (
        .posit(b),
        .sign(sign_b),
        .regime(regime_b),
        .exponent(exp_b),
        .fraction(frac_b),
        .is_NaR(is_NaR_b),
        .is_zero(is_zero_b),
        .abs_posit(abs_posit_b)
    );

    // Instantiate multiplication module
    posit_multiply #(WIDTH, ES) multiplier (
        .clk(clk),
//        .rst(rst),
        .sign_a(sign_a),
        .regime_a(regime_a),
        .exp_a(exp_a),
        .frac_a(frac_a),
        .sign_b(sign_b),
        .regime_b(regime_b),
        .exp_b(exp_b),
        .frac_b(frac_b),
        .sign_result(sign_result),
        .regime_result(regime_result),
        .exp_result(exp_result),
        .frac_result(frac_result),
        .abs_posit_a(abs_posit_a),
        .abs_posit_b(abs_posit_b),
        .done()
    );

    posit_encoder #(WIDTH, ES) encoder (
        .clk(clk),
        .sign(sign_result),
        .regime(regime_result),
        .exponent(exp_result),
        .fraction(frac_result),
        .is_NaR_a(is_NaR_a),
        .is_NaR_b(is_NaR_b),
        .is_zero_a(is_zero_a),
        .is_zero_b(is_zero_b),
        .res(res)
    );

endmodule


// Decoder module
module posit_decoder #(
    parameter WIDTH = 32,
    parameter ES = 3
) (
    input wire [WIDTH-1:0] posit,
    output wire sign,
    output reg signed [5:0] regime,
    output reg [ES-1:0] exponent,
    output reg [WIDTH-6:0] fraction,
    output wire is_NaR,
    output wire is_zero,
    output wire [WIDTH-1:0]abs_posit
);

    integer count;
    reg regime_sign;
    integer j;
    integer k;

    assign sign = posit[WIDTH-1];
    assign is_NaR = (posit == {1'b1, {(WIDTH-1){1'b0}}});
    assign is_zero = (posit == 0);

    assign abs_posit = sign ? (~posit[WIDTH-1:0] + 1'b1) : posit[WIDTH-1:0];
    
    integer es;
    always @(*) begin

        count = 0;
            regime_sign=abs_posit[WIDTH-2];
        
        k=0;
        for (j = 30; j >= 0; j = j - 1) begin
                if(abs_posit[j] != abs_posit[j - 1] && k==0)begin
//                    count=count+1;
                    k=-1;
                end
                else if (abs_posit[j] == abs_posit[j - 1] && k==0) begin
                    count = count + 1;
                end else begin
                   count=count;
                end       
        end
        count=count+1;

        if (regime_sign == 1'b0)
            regime = -count;
        else
            regime = count-1;
        exponent=3'b000;
        for (j = 0; j < 3  ; j = j + 1) begin
//            exponent = exponent + (abs_posit[j] << (es - 1));
                exponent=exponent<<1;
               exponent=exponent+abs_posit[WIDTH-count-3-j];
//                exponent = (exponent << 1) | abs_posit[j];
         
        end
//        for (j = WIDTH-3-count; j >WIDTH-6-count && j>=0 ; j = j -1) begin
////            exponent = exponent + (abs_posit[j] << (es - 1));
//                exponent=exponent<<1;
//               exponent=exponent+abs_posit[j];
////                exponent = (exponent << 1) | abs_posit[j];
         
//        end
        
          fraction = 27'b1;
        for (j = 0; j <26; j = j + 1) begin
            if(WIDTH-count-6-j>0)begin
                fraction=fraction<<1;
                fraction = fraction + abs_posit[WIDTH-(count+1)-5-j] ;
            end 
            else begin
                fraction=fraction;
             end
        end
//        for (j = WIDTH-6-count; j >=0; j = j - 1) begin
//            fraction=fraction<<1;
//            fraction = fraction + abs_posit[j] ;
//        end
    end
endmodule

// Multiplication module
module posit_multiply #(
    parameter WIDTH = 32,
    parameter ES = 3
) (
    input wire clk,
//    input wire rst,
    input wire sign_a,
    input wire [5:0] regime_a,
    input wire [ES-1:0] exp_a,
    input wire [WIDTH-6:0] frac_a,
    input wire sign_b,
    input wire [5:0] regime_b,
    input wire [ES-1:0] exp_b,
    input wire [WIDTH-6:0] frac_b,
    input wire [WIDTH-1:0] abs_posit_a,
    input wire [WIDTH-1:0] abs_posit_b,
    output reg sign_result,
    output reg signed [6:0] regime_result,
    output reg [ES-1:0] exp_result,
    output reg [WIDTH-6:0] frac_result,
    
    output reg done
);

    reg [2*(WIDTH-6)-1:0] frac_product;
    reg  [6:0] regime_sum;
    reg [3:0] exp_sum;
    integer cnt,c,j;
    reg [WIDTH-6:0] multiplicand;  
    reg [WIDTH-6:0] mult;  
    reg [2*(WIDTH-6)-1:0] partial_product;
    reg [5:0] shift_count;
    integer i;
    integer k,cnt;
    
        always@(*) begin
            frac_result=27'b0;
            cnt=$signed(regime_a);
//            c=$signed(regime_b);
            if(cnt<0)begin
                cnt = -cnt;
            end
            else begin
                cnt=cnt+1;
            end
            cnt=cnt+1;
            
            c=0;
            multiplicand=frac_b;
            mult=frac_b;            
            sign_result = sign_a ^ sign_b;

            regime_sum = {1'b0,regime_a} + {1'b0,regime_b};
            exp_sum = exp_a + exp_b;

            partial_product = 0;
        shift_count=0;
        for(i = 0; i <= 25; i = i+1) begin
            shift_count=shift_count+1;
            if(abs_posit_a[WIDTH-5-cnt-i]) begin
                mult=frac_b>>shift_count;
                multiplicand = multiplicand + mult;
            end
        end
        k=0;
        cnt=0;
        for( i=26;i>=0;i=i-1) begin
            cnt=cnt+1;
            if(multiplicand[i] && k==0)begin
                multiplicand=multiplicand<<cnt;
                k=-1;
            end
            else begin
                multiplicand=multiplicand;
             end
        end
//        for(i = WIDTH-1-3-cnt-1; i >= 0; i = i-1) begin
//            shift_count=shift_count+1;
//            if(abs_posit_a[i]) begin
//                mult=frac_b>>shift_count;
//                multiplicand = multiplicand + mult;
//            end
//        end

        frac_result = multiplicand;



            if (exp_sum > 7) begin
//                exp_sum <= exp_sum - 8; 
                regime_sum = regime_sum + 1'b1;  
            end

            exp_result = exp_sum[2:0];
            regime_result = regime_sum;
            done <= 1;
        end
//    end
endmodule




// Encoder module
module posit_encoder #(
    parameter WIDTH = 32,
    parameter ES = 3
) (
    input wire clk,
    input wire sign,
    input wire signed [6:0] regime,
    input wire [ES-1:0] exponent,
    input wire [WIDTH-6:0] fraction,
    input wire is_NaR_a,
    input wire is_NaR_b,
    input wire is_zero_a,
    input wire is_zero_b,
    output reg [WIDTH-1:0] res
);
    reg [WIDTH-6:0] fr;
    reg [26:0] encoded_regime;
    integer i, m, cnt;
    reg [WIDTH-1:0] result;

    always @(*) begin
        if (is_NaR_a || is_NaR_b) begin
            res = {1'b1, {WIDTH-1{1'b0}}};
        end else if (is_zero_a || is_zero_b) begin
            res = {WIDTH{1'b0}};
        end else begin
            cnt = 0;
            result = 32'b00000000000000000000000000000000;
            result=result+sign;
//            result[WIDTH-1] = sign;
            encoded_regime = 27'b0;
            fr = fraction;
//               m=0;
            // Find the first '1' in the fraction
//            for (i = WIDTH-6; i >= 0; i = i - 1) begin
//                if(m==-1)begin
//                    fr=fr;
//                 end
//                else if (fr[i]) begin
//                    fr = fr << cnt;
//                    m=-1;
//                end
//                cnt=cnt+1;
//            end
             m = $signed(regime) >= 0 ? $signed(regime)+1 : -$signed(regime);
            // Encode the regime
            if ($signed(regime) >= 0) begin
                for (i = 0;  i <=26; i = i + 1) begin
                    if (m>0)begin
                        result=result<<1;
                        result=result+1'b1;
                   end
                   else begin
                        result=result;
                    end
                    m=m-1;
                end
                result=result<<1;
                result = result+1'b0; 
            end else begin
                for (i = 0;  i <=26; i = i + 1) begin
                    if (m>0)begin
                        result=result<<1;
                        result=result+1'b0;
                   end
                   else begin
                        result=result;
                    end
                    m=m-1;
                end
                result=result<<1;
                result = result+1'b1; 
            end
//            if ($signed(regime) >= 0) begin
//                for (i = regime+1; i > 0 && i < WIDTH-2; i = i - 1) begin
//                    result=result<<1;
//                    result=result+1'b1;
//                end
//                result=result<<1;
//                result = result+1'b0; 
//            end else begin
//                for (i = -regime; i > 0 && i < WIDTH-2; i = i - 1) begin
//                    result=result<<1;
//                    result=result+1'b0;
//                end
//                result=result<<1;
//                result = result+1'b1; 
//            end

           
//            encoded_regime = encoded_regime << (26-m);
//            for (i = 26; i >= 26-m; i = i - 1) begin
//                result[i+4] = encoded_regime[i];
//            end

            // Place the exponent in the result
            result=result<<1;
            result=result+exponent[2];
            result=result<<1;
            result=result+exponent[1];
            result=result<<1;
            result=result+exponent[0];
             m = $signed(regime) >= 0 ? $signed(regime)+1 : -$signed(regime);
            // Place the fraction in the result
            cnt = 26;
            for (i = 0; i <= 25; i = i + 1) begin
                if(26-m>=0)begin
                    result=result<<1;
                    result = result + fr[cnt];
                    cnt = cnt - 1;
                end
                else begin
                    result=result;
                end
                m=m+1;
            end
//            for (i = 26-m; i >= 0; i = i - 1) begin
//                result=result<<1;
//                result = result + fr[cnt];
//                cnt = cnt - 1;
//            end
            res=result;
        end
    end
endmodule
