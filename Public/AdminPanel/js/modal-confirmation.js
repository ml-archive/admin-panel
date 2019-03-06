let modalConfirmation = (function() {
    return {
        confirm: function(element) {
            // Confirm modal title
            let modalTitle = $(element).data('header');
            modalTitle = !modalTitle ? 'Please confirm' : modalTitle;

            // Confirm modal text
            let modalText = $(element).data('text');
            modalText = !modalText ? 'Are you sure you want to continue?' : modalText;

            // Confirmation path
            let modalConfirmationPath = $(element).attr('href');

            // Confirmation type
            let modalConfirmButtonType = $(element).data('button');
            modalConfirmButtonType = !modalConfirmButtonType ? 'primary' : modalConfirmButtonType;

            // Confirmation button text
            let confirmButtonText = $(element).data('confirm-btn');
            confirmButtonText = !confirmButtonText ? 'Confirm' : confirmButtonText;

            // Dismiss button text
            let dismissButtonText = $(element).data('dismiss-btn');
            dismissButtonText = !dismissButtonText ? 'Close' : dismissButtonText;

            let closure = function(e) {
                e.preventDefault();

                let modal = `
                    <div class="modal fade" id="modalConfirmation" tabindex="-1" role="dialog" aria-labelledby="modalConfirmationLabel" aria-hidden="true">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <form method="POST" action="${modalConfirmationPath}" id="confirmModalForm">
                                    <div class="modal-header">
                                        <h5 class="modal-title">${modalTitle}</h5>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body">
                                        <p>${modalText}</p>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="submit" class="btn btn-${modalConfirmButtonType}">${confirmButtonText}</button>
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">${dismissButtonText}</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                `;

                $('body').append(modal);
                $('#modalConfirmation').modal();

                // Custom "Confirm"-action
                if (typeof modalConfirmation.actions.confirm === "function") {
                    // Identify confirm button, interrupt default behavior, execute custom action
                    let confirmBtn = $("#modalConfirmation .modal-footer button[type='submit']");

                    confirmBtn.click(function(event) {
                        event.preventDefault();
                        event.stopPropagation();
                        modalConfirmation.actions.confirm(event);
                    });
                }

                // Custom "Dismiss"-action
                if (typeof(modalConfirmation.actions.dismiss) === "function") {
                    // Identify dismiss button, interrupt default behavior, execute custom action
                    let dismissBtn = $("#modalConfirmation .modal-footer button[type='button']");

                    dismissBtn.click(function(event) {
                        event.stopPropagation();
                        event.preventDefault();
                        modalConfirmation.actions.dismiss(event);
                    });
                }

                $('#modalConfirmation').on('hidden.bs.modal', function (e) {
                    $('#modalConfirmation').remove();
                })
            };

            $(element).click(closure);
        },
        actions: {
            confirm: null,
            dismiss: null
        }
    }
})();

$( document ).ready(function() {
    $('[data-confirm="true"]').each(function() {
        modalConfirmation.confirm($(this));
    });
})