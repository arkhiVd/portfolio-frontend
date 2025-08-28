window.addEventListener('DOMContentLoaded', (event) => {

  const invokeURL = "https://863novc21g.execute-api.ap-south-1.amazonaws.com/prod";
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