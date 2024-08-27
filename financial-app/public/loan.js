document.getElementById('loanForm').addEventListener('submit', function(e) {
    e.preventDefault();

    const loanAmount = parseFloat(document.querySelector('input[name="loanAmount"]').value);
    const interestRate = parseFloat(document.querySelector('input[name="interestRate"]').value) / 100 / 12;
    const loanTerm = parseFloat(document.querySelector('input[name="loanTerm"]').value) * 12;
    const downPaymentPercentage = parseFloat(document.querySelector('input[name="downPayment"]').value) / 100;
    const downPayment = loanAmount * downPaymentPercentage;
    const principal = loanAmount - downPayment;

    const monthlyPayment = (principal * interestRate) / (1 - Math.pow(1 + interestRate, -loanTerm));

    document.getElementById('loanResult').innerText = 
        `Your monthly payment is $${monthlyPayment.toFixed(2)}`;
});
