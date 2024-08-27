let chart;

document.addEventListener('DOMContentLoaded', function() {
    const interestTypeSelect = document.querySelector('select[name="interestType"]');
    const compoundOptions = document.getElementById('compoundOptions');

    interestTypeSelect.addEventListener('change', function() {
        compoundOptions.style.display = this.value === 'compound' ? 'flex' : 'none';
    });

    document.getElementById('calcForm').addEventListener('submit', function(e) {
        e.preventDefault();
        calculateInterest();
    });

    document.querySelectorAll('.compound-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.compound-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            calculateInterest();
        });
    });

    // Initialize the chart container
    document.getElementById('chartContainer').style.display = 'none';
});

function calculateInterest() {
    const principal = parseFloat(document.querySelector('input[name="principal"]').value);
    const rate = parseFloat(document.querySelector('input[name="rate"]').value) / 100;
    const time = parseFloat(document.querySelector('input[name="time"]').value);
    const interestType = document.querySelector('select[name="interestType"]').value;
    const compoundFrequency = interestType === 'compound' ? 
        parseInt(document.querySelector('.compound-btn.active')?.dataset.frequency || '1') : 1;

    let interest, totalAmount;

    if (interestType === 'simple') {
        interest = principal * rate * time;
        totalAmount = principal + interest;
    } else {
        totalAmount = principal * Math.pow(1 + rate / compoundFrequency, compoundFrequency * time);
        interest = totalAmount - principal;
    }

    document.getElementById('result').innerHTML = `
        <p>Interest: ${formatCurrency(interest)}</p>
        <p>Total Amount: ${formatCurrency(totalAmount)}</p>
    `;

    updateChart(principal, rate, time, interestType, compoundFrequency);
}

function updateChart(principal, rate, time, interestType, compoundFrequency) {
    const labels = Array.from({length: time + 1}, (_, i) => i);
    const data = labels.map(year => calculateAmount(principal, rate, year, interestType, compoundFrequency));

    if (!chart) {
        const ctx = document.getElementById('interestChart').getContext('2d');
        chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels,
                datasets: [{
                    label: 'Balance Over Time',
                    data: data,
                    borderColor: 'rgb(75, 192, 192)',
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    fill: true,
                    tension: 0.1
                }]
            },
            options: getChartOptions()
        });
        // Show the chart container smoothly
        const chartContainer = document.getElementById('chartContainer');
        chartContainer.style.display = 'block';
        chartContainer.style.opacity = 0;
        setTimeout(() => {
            chartContainer.style.transition = 'opacity 0.5s ease-in-out';
            chartContainer.style.opacity = 1;
        }, 0);
        // Scroll to the chart
        chartContainer.scrollIntoView({ behavior: 'smooth', block: 'end' });
    } else {
        chart.data.labels = labels;
        chart.data.datasets[0].data = data;
        chart.update('none'); // Use 'none' to update without animation
    }
}

function getChartOptions() {
    return {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
            mode: 'index',
            intersect: false,
        },
        plugins: {
            tooltip: {
                callbacks: {
                    label: function(context) {
                        return 'Balance: ' + formatCurrency(context.parsed.y);
                    }
                }
            },
            legend: {
                display: false
            }
        },
        scales: {
            x: {
                title: {
                    display: true,
                    text: 'Years'
                }
            },
            y: {
                beginAtZero: true,
                ticks: {
                    callback: function(value, index, values) {
                        return formatCurrency(value);
                    }
                },
                title: {
                    display: true,
                    text: 'Balance'
                }
            }
        }
    };
}

function calculateAmount(principal, rate, time, interestType, compoundFrequency) {
    if (interestType === 'simple') {
        return principal * (1 + rate * time);
    } else {
        return principal * Math.pow(1 + rate / compoundFrequency, compoundFrequency * time);
    }
}

function formatCurrency(value) {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value);
}
