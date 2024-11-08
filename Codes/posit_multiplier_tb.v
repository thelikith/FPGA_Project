module posit_multiplier_tb;

    parameter WIDTH = 32;
    parameter ES = 3;

    reg clk;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
//    wire [WIDTH-1:0] res;

    posit_multiplier #(WIDTH, ES) uut (
        .clk(clk),
        .a(a),
        .b(b)
//        .res(res)
    );

    // Signals from decoder for monitoring
    wire sign_a, sign_b;
    wire signed [5:0] regime_a, regime_b;
    wire [ES-1:0] exp_a, exp_b;
    wire [WIDTH-6:0] frac_a, frac_b;
    wire is_NaR_a, is_NaR_b, is_zero_a, is_zero_b;
    wire [WIDTH-1:0] abs_posit_a, abs_posit_b;

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

    wire sign_result;
    wire signed [6:0] regime_result;
    wire [ES-1:0] exp_result;
    wire [WIDTH-6:0] frac_result;
//    wire done;

    posit_multiply #(WIDTH, ES) multiply (
        .clk(clk),
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
        .abs_posit_b(abs_posit_b)
//        .done(done)
    );

    wire [WIDTH-1:0] result;

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
        .res(result)
    );

    initial begin
        $monitor("Time: %0t | a: %h (Decoded: sign: %b, regime: %d, exponent: %d, fraction: %h, NaR: %b, Zero: %b) | b: %h (Decoded: sign: %b, regime: %d, exponent: %d, fraction: %h, NaR: %b, Zero: %b) | Mult. Result -> sign: %b, regime: %d, exponent: %d, fraction: %h |  result: %h",
            $time, a, sign_a, regime_a, exp_a, frac_a, is_NaR_a, is_zero_a,
            b, sign_b, regime_b, exp_b, frac_b, is_NaR_b, is_zero_b,
            sign_result, regime_result, exp_result, frac_result, result);
    end

    initial begin
        clk = 0;
        a=0;
        b=0;
        #4
        

        a = 32'b00111000000000000000000000000000; 
        b = 32'b00111000000000000000000000000000; 
        #10;

        a = 32'b01001000000000000000000000000000; 
        b = 32'b01001000000000000000000000000000; 
        #10;
        
        a = 32'b01111000000000000000000000000000; 
        b = 32'b01111000000000000000000000000000; 
        #10;

        a = 32'b11000000000000000000000000000000; 
        b = 32'b11000000000000000000000000000000; 
        #10;

        a = 32'b10111000000000000000000000000000; 
        b = 32'b10111000000000000000000000000000; 
        #10;

        a = 32'b01000101000000000000000000000000; 
        b = 32'b01000101000000000000000000000000; 
        #10;

        a = 32'b00110100000000000000000000000000; 
        b = 32'b00110100000000000000000000000000; 
        #10;

        a = 32'b00011100100100000000000000000000;
        b = 32'b00011100100100000000000000000000;
        #10;

        a = 32'b00111100100000100000000000000000;
        b = 32'b00111100100000100000000000000000;
        #10;

        a = 32'b00011100100100000000000000000000;
        b = 32'b00111100100000100000000000000000;
        #10
        
//        a = 32'b10000000000000000000000000000000; 
//        b = 32'b11000000000000000000000000000000; 
//        #10;

        $finish;
    end

    always #5 clk = ~clk;

endmodule
