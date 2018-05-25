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
            let modalConfirmationPath = $(element).attr('href')

            // Confirmation type
            let modalConfirmButtonType = $(element).data('button');
            modalConfirmButtonType = !modalConfirmButtonType ? 'primary' : modalConfirmButtonType

            let closure = function(e) {
                e.preventDefault();

                let modal = `
                    <div class="modal fade" id="modalConfirmation" tabindex="-1" role="dialog" aria-labelledby="modalConfirmationLabel" aria-hidden="true">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <form method="POST" action="${modalConfirmationPath}">
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
                                        <button type="submit" class="btn btn-${modalConfirmButtonType}">Confirm</button>
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                `;

                $('body').append(modal)
                $('#modalConfirmation').modal()
                $('#modalConfirmation').on('hidden.bs.modal', function (e) {
                    $('#modalConfirmation').remove()
                })
            };

            $(element).click(closure);
        }
    }
})();

$( document ).ready(function() {
    $('[data-confirm="true"]').each(function() {
        modalConfirmation.confirm($(this));
    });
})