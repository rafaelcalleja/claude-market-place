// AWS CLI Component Sample - Application JavaScript

(function() {
  'use strict';

  // Display deployment timestamp if available
  function displayDeploymentInfo() {
    const deploymentDate = new Date();
    console.log('Sample deployed at:', deploymentDate.toISOString());
    console.log('Powered by: to-be-continuous AWS CLI component');
  }

  // Add smooth scroll behavior
  function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      });
    });
  }

  // Add interactive features to buttons
  function initButtonInteractions() {
    const buttons = document.querySelectorAll('.button');
    buttons.forEach(button => {
      button.addEventListener('mouseenter', () => {
        console.log('Button hovered:', button.textContent);
      });
    });
  }

  // Check if deployed on CloudFront or S3
  function detectDeploymentEnvironment() {
    const hostname = window.location.hostname;
    let environment = 'Unknown';

    if (hostname.includes('cloudfront.net')) {
      environment = 'CloudFront';
    } else if (hostname.includes('s3-website') || hostname.includes('s3.amazonaws.com')) {
      environment = 'S3 Static Website';
    } else if (hostname === 'localhost' || hostname === '127.0.0.1') {
      environment = 'Local Development';
    }

    console.log('Deployment Environment:', environment);
    return environment;
  }

  // Add cache information display
  function displayCacheInfo() {
    const resourceTypes = {
      'text/html': 'HTML files cached with no-cache strategy',
      'text/css': 'CSS files cached for 1 year (immutable)',
      'application/javascript': 'JS files cached for 1 year (immutable)',
      'image/': 'Images cached for 30 days'
    };

    console.log('Cache Strategy:');
    Object.entries(resourceTypes).forEach(([type, strategy]) => {
      console.log(`  ${type}: ${strategy}`);
    });
  }

  // Initialize on DOM ready
  function init() {
    console.log('🚀 AWS CLI Component Sample Initialized');
    displayDeploymentInfo();
    initSmoothScroll();
    initButtonInteractions();
    detectDeploymentEnvironment();
    displayCacheInfo();

    // Add visual indicator that JS is loaded
    document.body.classList.add('js-loaded');
  }

  // Run initialization
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // Expose deployment info to window for debugging
  window.awsCliSample = {
    version: '1.0.0',
    component: 'to-be-continuous/awscli',
    variant: 'OIDC',
    getEnvironment: detectDeploymentEnvironment
  };

})();