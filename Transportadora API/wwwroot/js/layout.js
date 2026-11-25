/*
 * Menu lateral, barra superior (celular) e troca de senha — iguais em todas as páginas.
 * Cada página só precisa de:  <body data-pagina="clientes">  e  <aside id="sidebarHost" class="sidebar"></aside>
 * Depende de js/app.js (esc, apiFetch, sair, mostrarToast) e do Bootstrap já carregados.
 */
(function () {
    const perfil = localStorage.getItem('perfilAcesso');
    const nome = localStorage.getItem('usuarioNome') || '';
    const pagina = document.body.dataset.pagina;
    const host = document.getElementById('sidebarHost');
    if (!host) return;

    const ITENS = [
        { id: 'index',      href: 'index.html',      icone: '🏠', texto: 'Início',     perfis: ['admin', 'operador', 'motorista'] },
        { id: 'clientes',   href: 'clientes.html',   icone: '👥', texto: 'Clientes',   perfis: ['admin'] },
        { id: 'motoristas', href: 'motoristas.html', icone: '🪪', texto: 'Motoristas', perfis: ['admin', 'operador'] },
        { id: 'veiculos',   href: 'veiculos.html',   icone: '🚚', texto: 'Veículos',   perfis: ['admin', 'operador'] },
        { id: 'entregas',   href: 'entregas.html',   icone: '📦', texto: 'Entregas',   perfis: ['admin', 'operador', 'motorista'] }
    ];
    const ROTULO_PERFIL = { admin: 'Administrador', operador: 'Operador', motorista: 'Motorista' };

    // Perfil sem acesso a esta página: volta para o início (a API também bloqueia).
    const atual = ITENS.find(function (i) { return i.id === pagina; });
    if (atual && !atual.perfis.includes(perfil)) {
        window.location.href = 'index.html';
        return;
    }

    const links = ITENS.filter(function (i) { return i.perfis.includes(perfil); }).map(function (i) {
        return '<li><a href="' + i.href + '" class="nav-link' + (i.id === pagina ? ' active' : '') + '"' +
            (i.id === pagina ? ' aria-current="page"' : '') + '><span aria-hidden="true">' + i.icone + '</span>' + i.texto + '</a></li>';
    }).join('');

    host.setAttribute('aria-label', 'Menu principal');
    host.innerHTML =
        '<div class="sidebar-marca"><span class="logo" aria-hidden="true">🚚</span>TransPIM</div>' +
        '<ul class="nav flex-column gap-1 mb-auto">' + links + '</ul>' +
        '<div class="sidebar-usuario">' +
            '<div class="nome">' + esc(nome || 'Usuário') + '</div>' +
            '<span class="badge bg-secondary">' + esc(ROTULO_PERFIL[perfil] || perfil || '') + '</span>' +
            '<div class="acoes">' +
                '<button type="button" id="btnAlterarSenha" class="btn btn-sm btn-outline-light">Alterar senha</button>' +
                '<button type="button" id="btnSair" class="btn btn-sm btn-light">Sair</button>' +
            '</div>' +
        '</div>';

    // ---- barra superior + fundo escuro (só aparecem no celular, via CSS) ----
    const shell = host.parentElement;
    const topbar = document.createElement('header');
    topbar.className = 'topbar-mobile';
    topbar.innerHTML = '<span class="marca">🚚 TransPIM</span>' +
        '<button type="button" id="btnMenu" aria-label="Abrir menu" aria-expanded="false">☰</button>';
    shell.insertBefore(topbar, shell.firstChild);

    const fundo = document.createElement('div');
    fundo.className = 'sidebar-fundo';
    shell.appendChild(fundo);

    function alternarMenu(abrir) {
        host.classList.toggle('aberta', abrir);
        fundo.classList.toggle('aberto', abrir);
        document.getElementById('btnMenu').setAttribute('aria-expanded', String(abrir));
    }
    document.getElementById('btnMenu').addEventListener('click', function () { alternarMenu(!host.classList.contains('aberta')); });
    fundo.addEventListener('click', function () { alternarMenu(false); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') alternarMenu(false); });

    document.getElementById('btnSair').addEventListener('click', sair);

    // ---- modal de troca de senha ----
    const modal = document.createElement('div');
    modal.className = 'modal fade';
    modal.id = 'modalSenha';
    modal.tabIndex = -1;
    modal.setAttribute('aria-hidden', 'true');
    modal.innerHTML =
        '<div class="modal-dialog modal-dialog-centered"><div class="modal-content shadow-lg">' +
            '<div class="modal-header border-0 pb-0 pt-4 px-4"><h5 class="modal-title fw-bold">Alterar senha</h5>' +
            '<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button></div>' +
            '<div class="modal-body p-4"><form id="formSenha" novalidate>' +
                '<div class="mb-3"><label class="form-label small fw-bold text-muted" for="senhaAtual">SENHA ATUAL</label>' +
                '<input type="password" id="senhaAtual" class="form-control" autocomplete="current-password" required></div>' +
                '<div class="mb-3"><label class="form-label small fw-bold text-muted" for="novaSenha">NOVA SENHA (mín. 8 caracteres)</label>' +
                '<input type="password" id="novaSenha" class="form-control" autocomplete="new-password" minlength="8" required></div>' +
                '<div class="mb-4"><label class="form-label small fw-bold text-muted" for="confirmaSenha">CONFIRMAR NOVA SENHA</label>' +
                '<input type="password" id="confirmaSenha" class="form-control" autocomplete="new-password" required></div>' +
                '<div class="text-end"><button type="button" class="btn btn-light me-2" data-bs-dismiss="modal">Cancelar</button>' +
                '<button type="submit" class="btn btn-primary px-4">Salvar</button></div>' +
            '</form></div></div></div>';
    document.body.appendChild(modal);

    document.getElementById('btnAlterarSenha').addEventListener('click', function () {
        alternarMenu(false);
        bootstrap.Modal.getOrCreateInstance(modal).show();
    });

    document.getElementById('formSenha').addEventListener('submit', async function (e) {
        e.preventDefault();
        const atualEl = document.getElementById('senhaAtual');
        const novaEl = document.getElementById('novaSenha');
        const confirmaEl = document.getElementById('confirmaSenha');

        if (novaEl.value.length < 8) { mostrarToast('A nova senha precisa ter pelo menos 8 caracteres.', 'bg-danger'); return; }
        if (novaEl.value !== confirmaEl.value) { mostrarToast('A confirmação não confere com a nova senha.', 'bg-danger'); return; }

        try {
            const res = await apiFetch('/Auth/alterar-senha', {
                method: 'POST',
                body: JSON.stringify({ senhaAtual: atualEl.value, novaSenha: novaEl.value })
            });
            if (res.ok) {
                mostrarToast('Senha alterada com sucesso!', 'bg-success');
                e.target.reset();
                bootstrap.Modal.getOrCreateInstance(modal).hide();
            } else {
                mostrarToast(await mensagemDeErro(res, 'Não foi possível alterar a senha.'), 'bg-danger');
            }
        } catch (err) {
            mostrarToast('Falha na comunicação com a API.', 'bg-danger');
        }
    });
})();
