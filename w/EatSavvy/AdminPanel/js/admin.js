const API_BASE_URL = 'https://api.eatsavvy.com/v1'; // Replace with your actual API endpoint
let authToken = localStorage.getItem('authToken');

// DOM Elements
const loginForm = document.getElementById('loginForm');
const dealManagement = document.getElementById('dealManagement');
const dealsTableBody = document.getElementById('dealsTableBody');
const addDealForm = document.getElementById('addDealForm');
const userEmailElement = document.getElementById('userEmail');

// Check authentication status on page load
document.addEventListener('DOMContentLoaded', () => {
    if (authToken) {
        showDealManagement();
        fetchDeals();
    } else {
        showLoginForm();
    }
});

// Login Form Handler
document.getElementById('login').addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    try {
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, password }),
        });

        if (response.ok) {
            const data = await response.json();
            authToken = data.token;
            localStorage.setItem('authToken', authToken);
            userEmailElement.textContent = email;
            showDealManagement();
            fetchDeals();
        } else {
            alert('Invalid credentials');
        }
    } catch (error) {
        console.error('Login error:', error);
        alert('Login failed. Please try again.');
    }
});

// Add Deal Handler
document.getElementById('submitDeal').addEventListener('click', async () => {
    const formData = new FormData(addDealForm);
    const dealData = {
        title: formData.get('title'),
        description: formData.get('description'),
        discount: formData.get('discount'),
        dealType: formData.get('dealType'),
        expirationDate: new Date(formData.get('expirationDate')).toISOString(),
        terms: formData.get('terms'),
        isExclusive: formData.get('isExclusive') === 'on'
    };

    try {
        const response = await fetch(`${API_BASE_URL}/deals`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            },
            body: JSON.stringify(dealData)
        });

        if (response.ok) {
            bootstrap.Modal.getInstance(document.getElementById('addDealModal')).hide();
            addDealForm.reset();
            fetchDeals();
        } else {
            alert('Failed to add deal');
        }
    } catch (error) {
        console.error('Add deal error:', error);
        alert('Failed to add deal. Please try again.');
    }
});

// Fetch and Display Deals
async function fetchDeals() {
    try {
        const response = await fetch(`${API_BASE_URL}/deals`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });

        if (response.ok) {
            const deals = await response.json();
            displayDeals(deals);
        } else {
            throw new Error('Failed to fetch deals');
        }
    } catch (error) {
        console.error('Fetch deals error:', error);
        alert('Failed to load deals');
    }
}

function displayDeals(deals) {
    dealsTableBody.innerHTML = deals.map(deal => `
        <tr>
            <td>${escapeHtml(deal.title)}</td>
            <td>${escapeHtml(deal.description)}</td>
            <td>${escapeHtml(deal.discount)}</td>
            <td>${new Date(deal.expirationDate).toLocaleDateString()}</td>
            <td>
                <button class="btn btn-sm btn-warning" onclick="editDeal('${deal.id}')">Edit</button>
                <button class="btn btn-sm btn-danger" onclick="deleteDeal('${deal.id}')">Delete</button>
            </td>
        </tr>
    `).join('');
}

// Delete Deal Handler
async function deleteDeal(dealId) {
    if (!confirm('Are you sure you want to delete this deal?')) return;

    try {
        const response = await fetch(`${API_BASE_URL}/deals/${dealId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });

        if (response.ok) {
            fetchDeals();
        } else {
            alert('Failed to delete deal');
        }
    } catch (error) {
        console.error('Delete deal error:', error);
        alert('Failed to delete deal');
    }
}

// Edit Deal Handler
async function editDeal(dealId) {
    try {
        const response = await fetch(`${API_BASE_URL}/deals/${dealId}`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });

        if (response.ok) {
            const deal = await response.json();
            // Populate form with deal data
            const modal = new bootstrap.Modal(document.getElementById('addDealModal'));
            document.querySelector('[name="title"]').value = deal.title;
            document.querySelector('[name="description"]').value = deal.description;
            document.querySelector('[name="discount"]').value = deal.discount;
            document.querySelector('[name="dealType"]').value = deal.dealType;
            document.querySelector('[name="expirationDate"]').value = new Date(deal.expirationDate).toISOString().slice(0, 16);
            document.querySelector('[name="terms"]').value = deal.terms;
            document.querySelector('[name="isExclusive"]').checked = deal.isExclusive;
            
            // Change submit button to update
            const submitButton = document.getElementById('submitDeal');
            submitButton.textContent = 'Update Deal';
            submitButton.onclick = () => updateDeal(dealId);
            
            modal.show();
        }
    } catch (error) {
        console.error('Edit deal error:', error);
        alert('Failed to load deal details');
    }
}

// Update Deal Handler
async function updateDeal(dealId) {
    const formData = new FormData(addDealForm);
    const dealData = {
        title: formData.get('title'),
        description: formData.get('description'),
        discount: formData.get('discount'),
        dealType: formData.get('dealType'),
        expirationDate: new Date(formData.get('expirationDate')).toISOString(),
        terms: formData.get('terms'),
        isExclusive: formData.get('isExclusive') === 'on'
    };

    try {
        const response = await fetch(`${API_BASE_URL}/deals/${dealId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            },
            body: JSON.stringify(dealData)
        });

        if (response.ok) {
            bootstrap.Modal.getInstance(document.getElementById('addDealModal')).hide();
            addDealForm.reset();
            fetchDeals();
        } else {
            alert('Failed to update deal');
        }
    } catch (error) {
        console.error('Update deal error:', error);
        alert('Failed to update deal');
    }
}

// Utility Functions
function showLoginForm() {
    loginForm.classList.remove('d-none');
    dealManagement.classList.add('d-none');
}

function showDealManagement() {
    loginForm.classList.add('d-none');
    dealManagement.classList.remove('d-none');
}

function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "<")
        .replace(/>/g, ">")
        .replace(/"/g, """)
        .replace(/'/g, "&#039;");
}
