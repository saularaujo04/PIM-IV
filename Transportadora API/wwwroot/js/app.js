/*
<<<<<<< HEAD
 * Utilitários compartilhados do painel web (carregado por todas as páginas).
 *  - apiFetch: chama a API na MESMA origem (/api/...), enviando o JWT.
 *  - esc: escapa texto antes de colocar em innerHTML (evita XSS).
 *  - exigirLogin / sair: controle de sessão no navegador.
 *  - mostrarToast: avisos flutuantes padronizados.
 *  - UI: estados de tabela (carregando, vazio, erro) e busca.
 *  - validarCpf / validarCnpj / validarPlaca: validações de formulário.
=======
 * Utilitários compartilhados do painel web (carregado por todas as páginas, exceto login).
 *  - apiFetch: chama a API na MESMA origem (/api/...), enviando o JWT.
 *  - esc: escapa texto antes de colocar em innerHTML (evita XSS).
 *  - exigirLogin / sair: controle de sessão no navegador.
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
 */
(function () {
    const API = '/api';
    const CHAVES_SESSAO = ['token', 'perfilAcesso', 'usuarioNome'];

    window.esc = function (valor) {
        return String(valor ?? '').replace(/[&<>"']/g, function (c) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
    };

    window.sair = function () {
        CHAVES_SESSAO.forEach(function (k) { localStorage.removeItem(k); });
        window.location.href = 'login.html';
    };

    window.exigirLogin = function () {
        if (!localStorage.getItem('token')) {
            window.location.href = 'login.html';
            return false;
        }
        return true;
    };

    window.apiFetch = async function (caminho, opcoes) {
        opcoes = opcoes || {};
        const headers = Object.assign({}, opcoes.headers);
        const token = localStorage.getItem('token');
        if (token) headers['Authorization'] = 'Bearer ' + token;
        if (opcoes.body && !headers['Content-Type']) headers['Content-Type'] = 'application/json';

        const res = await fetch(API + caminho, Object.assign({}, opcoes, { headers: headers }));
        if (res.status === 401) window.sair(); // token ausente, inválido ou expirado
        return res;
    };

    // Lê a mensagem de erro devolvida pela API (campo "mensagem" ou erros de validação).
    window.mensagemDeErro = async function (res, padrao) {
        try {
            const j = await res.json();
            if (j.mensagem) return j.mensagem;
            if (j.errors) return Object.values(j.errors).flat().join(' ');
        } catch (e) { /* corpo vazio ou não-JSON */ }
        return padrao;
    };

    // Índice = código do enum StatusEntrega (0 a 3).
    window.STATUS_ENTREGA = [
<<<<<<< HEAD
        { rotulo: 'Pendente',    classe: 's0' },
        { rotulo: 'Em trânsito', classe: 's1' },
        { rotulo: 'Concluída',   classe: 's2' },
        { rotulo: 'Ocorrência',  classe: 's3' }
    ];

    window.badgeStatus = function (codigo, descricao) {
        const st = window.STATUS_ENTREGA[codigo] || { rotulo: descricao || '-', classe: '' };
        return '<span class="badge-status ' + st.classe + '">' + window.esc(st.rotulo) + '</span>';
    };

    // ------------------------------------------------------------------ toast
    window.mostrarToast = function (mensagem, corFundo) {
        let host = document.getElementById('toastHost');
        if (!host) {
            host = document.createElement('div');
            host.id = 'toastHost';
            host.className = 'toast-container position-fixed top-0 end-0 p-3';
            host.style.zIndex = 2000;
            document.body.appendChild(host);
        }
        const el = document.createElement('div');
        el.className = 'toast align-items-center text-white border-0 shadow-lg ' + (corFundo || 'bg-dark');
        el.setAttribute('role', 'alert');
        el.setAttribute('aria-live', 'assertive');
        el.innerHTML = '<div class="d-flex"><div class="toast-body fw-semibold"></div>' +
            '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Fechar"></button></div>';
        el.querySelector('.toast-body').textContent = mensagem;
        host.appendChild(el);
        el.addEventListener('hidden.bs.toast', function () { el.remove(); });
        new bootstrap.Toast(el, { delay: 3500 }).show();
    };

    // --------------------------------------------------- estados de tabela / busca
    function normalizar(t) {
        return String(t || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
    }

    window.UI = {
        carregando: function (tbodyId, colunas, linhas) {
            const tbody = document.getElementById(tbodyId);
            if (!tbody) return;
            let html = '';
            for (let i = 0; i < (linhas || 4); i++) {
                html += '<tr data-estado="1">';
                for (let c = 0; c < colunas; c++) html += '<td class="py-3"><span class="skeleton"></span></td>';
                html += '</tr>';
            }
            tbody.innerHTML = html;
        },
        vazio: function (tbodyId, colunas, texto) {
            const tbody = document.getElementById(tbodyId);
            if (tbody) tbody.innerHTML = '<tr data-estado="1"><td colspan="' + colunas + '" class="estado-vazio">' + window.esc(texto) + '</td></tr>';
        },
        erro: function (tbodyId, colunas, texto) {
            const tbody = document.getElementById(tbodyId);
            if (tbody) tbody.innerHTML = '<tr data-estado="1"><td colspan="' + colunas + '" class="estado-erro">' + window.esc(texto) + '</td></tr>';
        },
        // Filtra as linhas da tabela conforme o texto digitado (ignora acentos e maiúsculas).
        // filtroExtra(tr) é opcional (ex.: filtro por status). Devolve a função que reaplica os filtros.
        ligarBusca: function (inputId, tbodyId, filtroExtra) {
            const input = document.getElementById(inputId);
            const tbody = document.getElementById(tbodyId);
            if (!input || !tbody) return function () {};
            function aplicar() {
                const termo = normalizar(input.value.trim());
                Array.prototype.forEach.call(tbody.rows, function (tr) {
                    if (tr.dataset.estado) return;
                    const textoOk = termo === '' || normalizar(tr.textContent).includes(termo);
                    const extraOk = !filtroExtra || filtroExtra(tr);
                    tr.hidden = !(textoOk && extraOk);
                });
            }
            input.addEventListener('input', aplicar);
            return aplicar;
        }
    };

    // ---------------------------------------------------------------- validações
    function digitos(v) { return String(v || '').replace(/\D/g, ''); }

    window.validarCpf = function (valor) {
        const d = digitos(valor);
        if (d.length !== 11 || /^(\d)\1+$/.test(d)) return false;
        for (let n = 9; n <= 10; n++) {
            let soma = 0;
            for (let i = 0; i < n; i++) soma += Number(d[i]) * (n + 1 - i);
            if (Number(d[n]) !== (soma * 10) % 11 % 10) return false;
        }
        return true;
    };

    window.validarCnpj = function (valor) {
        const d = digitos(valor);
        if (d.length !== 14 || /^(\d)\1+$/.test(d)) return false;
        const calc = function (pesos) {
            let soma = 0;
            for (let i = 0; i < pesos.length; i++) soma += Number(d[i]) * pesos[i];
            const r = soma % 11;
            return r < 2 ? 0 : 11 - r;
        };
        return calc([5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]) === Number(d[12]) &&
               calc([6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]) === Number(d[13]);
    };

    window.validarCpfOuCnpj = function (valor) {
        const n = digitos(valor).length;
        return n === 11 ? window.validarCpf(valor) : n === 14 ? window.validarCnpj(valor) : false;
    };

    window.validarPlaca = function (valor) {
        return /^[A-Za-z]{3}-?[0-9][A-Za-z0-9][0-9]{2}$/.test(String(valor || '').trim());
    };

    // Marca/desmarca o erro de um campo para o Bootstrap (.was-validated) mostrar a mensagem.
    window.validarCampo = function (inputId, ok, mensagem) {
        const el = document.getElementById(inputId);
        if (el) el.setCustomValidity(ok ? '' : mensagem);
    };
=======
        { rotulo: 'Pendente',    classe: 'bg-warning text-dark' },
        { rotulo: 'Em trânsito', classe: 'bg-primary' },
        { rotulo: 'Concluída',   classe: 'bg-success' },
        { rotulo: 'Ocorrência',  classe: 'bg-danger' }
    ];
>>>>>>> 92e8d435a95bec0bbac803957557f44b4c03799d
})();
