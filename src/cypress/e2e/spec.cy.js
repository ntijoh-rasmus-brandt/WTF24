describe('Check login', () => { 

  it('shows login form', () => { 
    cy.visit('http://localhost:9292/users/login')
    cy.get('form').should('exist')
  })

  it('login user', () => { 
    cy.visit('http://localhost:9292/users/login')
    cy.get('form input[name="username"]').type('Leon') 
    cy.get('input[name="password"]').type('Leon') 
    cy.get('form').submit() 
    cy.location('pathname').should('eq', '/products/tag/All')
  })

})