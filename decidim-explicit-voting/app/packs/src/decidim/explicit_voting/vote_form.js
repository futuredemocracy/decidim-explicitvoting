$(() => {
  const $form = $(".vote_form");
  
  if ($form.length > 0) {
    // Obsługa potwierdzenia głosowania
    $form.on("submit", (event) => {
      const confirmed = confirm("Czy na pewno chcesz oddać głos? Tej operacji nie można cofnąć.");
      if (!confirmed) {
        event.preventDefault();
      }
    });

    // Walidacja formularza
    const validateForm = () => {
      const $submitButton = $form.find("button[type='submit']");
      const $selectedOption = $form.find("input[type='radio']:checked");
      
      if ($selectedOption.length === 0) {
        $submitButton.prop("disabled", true);
      } else {
        $submitButton.prop("disabled", false);
      }
    };

    // Aktualizacja stanu przycisku submit przy zmianie wyboru
    $form.find("input[type='radio']").on("change", validateForm);

    // Inicjalna walidacja
    validateForm();
  }

  // Obsługa odświeżania wyników
  const $results = $(".voting-results");
  if ($results.length > 0) {
    const refreshResults = () => {
      const url = $results.data("refresh-url");
      if (url) {
        $.get(url, (response) => {
          $results.html(response);
        });
      }
    };

    // Odświeżaj wyniki co 30 sekund jeśli głosowanie jest aktywne
    if ($results.data("active")) {
      setInterval(refreshResults, 30000);
    }
  }

  // Obsługa eksportu protokołu
  const $exportButton = $(".export-protocol");
  if ($exportButton.length > 0) {
    $exportButton.on("click", (event) => {
      event.preventDefault();
      const url = $exportButton.attr("href");
      
      window.open(url, "_blank");
    });
  }
}); 