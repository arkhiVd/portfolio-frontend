window.addEventListener('DOMContentLoaded', (event) => {

  const invokeURL = "https://a4mif6uld5.execute-api.ap-south-2.amazonaws.com/prod/visitors";
  fetch(invokeURL, { method: 'POST' })
    .then(response => response.json())
    .then(data => {
      const count = data.count;
      document.getElementById("visitor-count").textContent = count;
    })
    .catch(error => {
      console.error('Error fetching visitor count:', error);
      document.getElementById("visitor-count").textContent = 'N/A';
    });
});